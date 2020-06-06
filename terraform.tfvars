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

#ASG
lc_instance_type = "t2.micro"
asg_max          = "2"
asg_min          = "1"
asg_grace        = "300"
asg_hct          = "EC2"
asg_cap          = "2"

#AMI
#Premade image contains apache
ami_id = "ami-045fbdb7b9d437752"

#Keys
public_key_path   = "/root/.ssh/id_rsa.pub"
key_name          = "id_rsa"