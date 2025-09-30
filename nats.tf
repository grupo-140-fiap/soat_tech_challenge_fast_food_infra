# Public IP
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-${local.env}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone_1.id
  tags = {
    Name = "nat-${local.env}"
  }

  depends_on = [ aws_internet_gateway.igw ]
}