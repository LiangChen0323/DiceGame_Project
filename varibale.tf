variable "aws_region" {}
variable "aws_profile" {}

variable "vpc_cidr" {}

variable "cidrs" {
  type = map(string)
}

data "aws_availability_zones" "available" {}

variable "domain_name" {}

#ELB
variable "elb_healthy_threshold" {}
variable "elb_unhealthy_threshold" {}
variable "elb_timeout" {}
variable "elb_interval" {}

#ASG
variable "lc_instance_type" {}
variable "asg_max" {}
variable "asg_min" {}
variable "asg_grace" {}
variable "asg_hct" {}
variable "asg_cap" {}

#AMI
variable "ami_id" {}
