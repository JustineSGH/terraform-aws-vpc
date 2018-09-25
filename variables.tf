variable "aws_region" {
  type = "string"
  description = "default region"
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = "string"
  description = "default cidr"
  default = "172.24.0.0/16"
}

variable "vpc_name" {
  type = "string"
  description = "vpc name"
}
variable "aws_availabilities_zones" {
  type = "list"
  description = "availabilities zones"
  default = ["a", "b", "c"]
}

variable "aws_public_key" {
  type = "string"
  description = "Clef publique"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgb4KJX+Rtdm4rfAllGeviFxt1ONlj8zwbHaaoCIbpBr52re3xT1LND/tiQyool0qL9iZQIjd89//EPXNzlvNPXM+XJhN5A2zgTmHanAoJt+6N6LDJRCUYfRI9ooJzkWsraB7IqAPe1/lxb8OH0LZjS+OYoGn/0zVzlEeKZlSJSSf+GF98AHKcWxvUVpU/E++Q7fmsHdCCYDzxf6SGpUzgVC+WiIJN/u+c2uAIF0ZJ/mdgBZhOi85ISuVfnXeYKvxVfZry7jsLjVCJrLOBBdWCY5twHgsCdjKWDqkfVRVNoam/2e+QKsJnyxg8ajlYLVrQCiIXgf9S6KjMc4VtvOqP"
}