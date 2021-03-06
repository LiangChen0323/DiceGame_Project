aws_profile = "liangchen"
aws_region  = "eu-west-2"
vpc_cidr    = "10.0.0.0/16"

cidrs = {
  public1  = "10.0.1.0/24"
  private1 = "10.0.2.0/24"
  private2 = "10.0.3.0/24"
}

domain_name = "liangchen0323"

#ELB
elb_healthy_threshold   = "2"
elb_unhealthy_threshold = "2"
elb_timeout             = "3"
elb_interval            = "30"

#AMI
dev_ami = "ami-032598fcc7e9d1c7a"
dev_instance_type = "t2.micro"

#Keys
public_key_path   = "/root/.ssh/id_rsa.pub"
key_name          = "id_rsa"

#ASG
lc_instance_type = "t2.micro"
asg_max          = "2"
asg_min          = "1"
asg_grace        = "300"
asg_hct          = "EC2"
asg_cap          = "2"

#Route53
zone_id = "Z0016315HM5HFEENTSBN"