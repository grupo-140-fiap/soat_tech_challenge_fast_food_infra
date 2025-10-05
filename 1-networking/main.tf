terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.13.2"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Private Subnets
resource "aws_subnet" "private_zone_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_zone_1_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name                                                = "private-subnet-${var.availability_zone_1}-${var.environment}"
    Environment                                         = var.environment
    Project                                             = var.project_name
    "kubernetes.io/role/internal-elb"                   = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}"     = "owned"
  }
}

resource "aws_subnet" "private_zone_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_zone_2_cidr
  availability_zone = var.availability_zone_2

  tags = {
    Name                                                = "private-subnet-${var.availability_zone_2}-${var.environment}"
    Environment                                         = var.environment
    Project                                             = var.project_name
    "kubernetes.io/role/internal-elb"                   = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}"     = "owned"
  }
}

# Public Subnets
resource "aws_subnet" "public_zone_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_zone_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "public-subnet-${var.availability_zone_1}-${var.environment}"
    Environment                                     = var.environment
    Project                                         = var.project_name
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_zone_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "public-subnet-${var.availability_zone_2}-${var.environment}"
    Environment                                     = var.environment
    Project                                         = var.project_name
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "igw-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "nat-eip-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone_1.id

  tags = {
    Name        = "nat-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "rt-private-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "rt-public-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Associations - Private
resource "aws_route_table_association" "private_zone_1" {
  subnet_id      = aws_subnet.private_zone_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone_2" {
  subnet_id      = aws_subnet.private_zone_2.id
  route_table_id = aws_route_table.private.id
}

# Route Table Associations - Public
resource "aws_route_table_association" "public_zone_1" {
  subnet_id      = aws_subnet.public_zone_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_zone_2" {
  subnet_id      = aws_subnet.public_zone_2.id
  route_table_id = aws_route_table.public.id
}