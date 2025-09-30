resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  # Habilita a resolução de DNS para a VPC
  enable_dns_support = true
  
  # Habilita nomes de host DNS para a VPC
  enable_dns_hostnames = true
  
  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "private_zone_1" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.zone1

  tags = {
    Name = "private-subnet-${local.zone1}-${local.env}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.eks_name}-${local.env}" = "owned"
  }
}

resource "aws_subnet" "private_zone_2" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.zone2

  tags = {
    Name = "private-subnet-${local.zone2}-${local.env}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.eks_name}-${local.env}" = "owned"
  }
}

resource "aws_subnet" "public_zone_1" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.64.0/19"
  availability_zone = local.zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${local.zone1}-${local.env}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.eks_name}-${local.env}" = "owned"
  }
}

resource "aws_subnet" "public_zone_2" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.96.0/19"
  availability_zone = local.zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${local.zone2}-${local.env}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.eks_name}-${local.env}" = "owned"
  }
}