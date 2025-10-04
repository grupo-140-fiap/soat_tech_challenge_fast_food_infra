output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_zone_1.id, aws_subnet.private_zone_2.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_zone_1.id, aws_subnet.public_zone_2.id]
}

output "private_subnet_zone_1_id" {
  description = "ID of private subnet in zone 1"
  value       = aws_subnet.private_zone_1.id
}

output "private_subnet_zone_2_id" {
  description = "ID of private subnet in zone 2"
  value       = aws_subnet.private_zone_2.id
}

output "public_subnet_zone_1_id" {
  description = "ID of public subnet in zone 1"
  value       = aws_subnet.public_zone_1.id
}

output "public_subnet_zone_2_id" {
  description = "ID of public subnet in zone 2"
  value       = aws_subnet.public_zone_2.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}