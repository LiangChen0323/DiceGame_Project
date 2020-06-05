variable "aws_region" {}
variable "aws_profile" {}

variable "vpc_cidr" {}

variable "cidrs" {
  type = map(string)
}

data "aws_availability_zones" "available" {}