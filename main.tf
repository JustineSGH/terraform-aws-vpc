### Backend definition

/*terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}*/

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "justine-vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name = "${var.vpc_name}"
  }
}
resource "aws_subnet" "justine-private" {
  vpc_id     = "${aws_vpc.justine-vpc.id}"
  count = "${length(var.aws_availabilities_zones)}"
  cidr_block = "${cidrsubnet(aws_vpc.justine-vpc.cidr_block, 4, count.index)}"
  availability_zone = "${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  tags {
    Name = "justine-private-${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  }
}

resource "aws_subnet" "justine-public" {
  vpc_id     = "${aws_vpc.justine-vpc.id}"
  count = "${length(var.aws_availabilities_zones)}"
  cidr_block = "${cidrsubnet(aws_vpc.justine-vpc.cidr_block, 4, 15-count.index)}"
  availability_zone = "${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  tags {
    Name = "justine-public-${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  }
}

resource "aws_internet_gateway" "justine-igw" {
  vpc_id = "${aws_vpc.justine-vpc.id}"
  tags {
    Name = "justine-igw"
  }
}

data "aws_ami" "justine-ami-nat" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*-x86_64-ebs"]
  }
}

#resource "aws_key_pair" "justine-public-key" {
# key_name   = "justine-public-key"
# public_key = "${var.aws_public_key}"
#}

resource "aws_security_group" "nat" {
  name = "nat"
  vpc_id = "${aws_vpc.justine-vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.justine-vpc.cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "justine-nat" {
  ami           = "${data.aws_ami.justine-ami-nat.id}"
  instance_type = "t2.medium"
  count = "${length(var.aws_availabilities_zones)}"
  tags {
    Name = "justine-nat-${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  }
  security_groups = ["${aws_security_group.nat.id}"]
  #key_name = "${aws_key_pair.niki-public-key.id}"
  subnet_id = "${aws_subnet.justine-public.*.id[count.index]}"
}

resource "aws_eip" "justine-eip" {
  vpc      = true
  count = "${length(var.aws_availabilities_zones)}"
  instance = "${aws_instance.justine-nat.*.id[count.index]}"
}

resource "aws_eip_association" "justine-eip-association"{
  count = "${length(var.aws_availabilities_zones)}"
  instance_id = "${aws_instance.justine-nat.*.id[count.index]}"
  allocation_id = "${aws_eip.justine-eip.*.id[count.index]}"
}

resource "aws_route_table" "justine-route-table-public" {
  vpc_id = "${aws_vpc.justine-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.justine-igw.id}"
  }

  tags {
    Name = "justine-route-table-public"
  }
}

resource "aws_route_table" "justine-route-table-private" {
  vpc_id = "${aws_vpc.justine-vpc.id}"
  count = "${length(var.aws_availabilities_zones)}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.justine-nat.*.id[count.index]}"
  }

  tags {
    Name = "justine-route-table-private-${var.aws_region}${var.aws_availabilities_zones[count.index]}"
  }
}

resource "aws_route_table_association" "justine-route-table-association-private" {
  count = "${length(var.aws_availabilities_zones)}"
  route_table_id = "${aws_route_table.justine-route-table-private.*.id[count.index]}"
  subnet_id = "${aws_subnet.justine-private.*.id[count.index]}"
}

resource "aws_route_table_association" "justine-route-table-association-public" {
  count = "${length(var.aws_availabilities_zones)}"
  route_table_id = "${aws_route_table.justine-route-table-public.id}"
  subnet_id = "${aws_subnet.justine-public.*.id[count.index]}"
}
