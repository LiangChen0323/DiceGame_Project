provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

// VPC
resource "aws_vpc" "DiceGame_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "DiceGame_vpc"
  }
}


// Internet Gateway
resource "aws_internet_gateway" "DiceGame_internet_gateway" {
  vpc_id = aws_vpc.DiceGame_vpc.id
  tags = {
    Name = "DiceGame_igw"
  }
}

// Route table: Private and Public
// Public Route table
resource "aws_route_table" "DiceGame_public_rt" {
  vpc_id = aws_vpc.DiceGame_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DiceGame_internet_gateway.id
  }

  tags = {
    Name = "DiceGame_public"
  }
}

// Private Route table
resource "aws_default_route_table" "DiceGame_private_rt" {
  default_route_table_id = aws_vpc.DiceGame_vpc.default_route_table_id

  tags = {
    Name = "DiceGame_private"
  }
}

// Subnets
// Public
resource "aws_subnet" "DiceGame_public1_subnet" {
  vpc_id                  = aws_vpc.DiceGame_vpc.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "DiceGame_public1"
  }
}

// Private
resource "aws_subnet" "DiceGame_private1_subnet" {
  vpc_id                  = aws_vpc.DiceGame_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "DiceGame_private1"
  }
}

resource "aws_subnet" "DiceGame_private2_subnet" {
  vpc_id                  = aws_vpc.DiceGame_vpc.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "DiceGame_private2"
  }
}

// Subnet Asscociations
resource "aws_route_table_association" "DiceGame_public_assoc" {
  subnet_id      = aws_subnet.DiceGame_public1_subnet.id
  route_table_id = aws_route_table.DiceGame_public_rt.id
}

resource "aws_route_table_association" "DiceGame_private1_assoc" {
  subnet_id      = aws_subnet.DiceGame_private1_subnet.id
  route_table_id = aws_default_route_table.DiceGame_private_rt.id
}

resource "aws_route_table_association" "DiceGame_private2_assoc" {
  subnet_id      = aws_subnet.DiceGame_private2_subnet.id
  route_table_id = aws_default_route_table.DiceGame_private_rt.id
}

# Public Security group for elb 
resource "aws_security_group" "DiceGame_public_sg" {
  name        = "DiceGame_public_sg"
  description = "Used for the elastic load balancer for public access"
  vpc_id      = aws_vpc.DiceGame_vpc.id

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security group for EC2 instances
resource "aws_security_group" "DiceGame_private_sg" {
  name        = "DiceGame_private_sg"
  description = "Used for private instances"
  vpc_id      = aws_vpc.DiceGame_vpc.id

  # Access only from VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load balancer 
resource "aws_elb" "DiceGame_elb" {
  name = "${var.domain_name}-elb"

  subnets = [aws_subnet.DiceGame_public1_subnet.id]

  security_groups = [aws_security_group.DiceGame_public_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    target              = "TCP:80"
    interval            = var.elb_interval
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "DiceGame_${var.domain_name}-elb"
  }
}

resource "aws_key_pair" "DiceGame_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Launch configuration 
resource "aws_launch_configuration" "DiceGame_lc" {
  name_prefix          = "DiceGame_lc-"
  image_id             = var.ami_id
  instance_type        = var.lc_instance_type
  security_groups      = [aws_security_group.DiceGame_private_sg.id]
  key_name             = aws_key_pair.DiceGame_auth.id
  user_data            = file("userdata")
  lifecycle {
    create_before_destroy = true
  }
}

# ASG
resource "aws_autoscaling_group" "DiceGame_asg" {
  name                      = "asg-${aws_launch_configuration.DiceGame_lc.id}"
  max_size                  = var.asg_max
  min_size                  = var.asg_min
  health_check_grace_period = var.asg_grace
  health_check_type         = var.asg_hct
  desired_capacity          = var.asg_cap
  force_delete              = true
  load_balancers            = [aws_elb.DiceGame_elb.id]

  vpc_zone_identifier = [aws_subnet.DiceGame_private1_subnet.id, aws_subnet.DiceGame_private2_subnet.id]

  launch_configuration = aws_launch_configuration.DiceGame_lc.name
  
  lifecycle {
    create_before_destroy = true
  }
}