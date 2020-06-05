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