output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "security_group" {
  value = aws_security_group.infra_sg.id
}

output "vpc_id" {
  value = aws_vpc.infra_vpc.id
}

output "public_subnet_1" {
  value = element(aws_subnet.public_subnet.*.id, 1)
}

output "public_subnet_2" {
  value = element(aws_subnet.public_subnet.*.id, 2)
}

output "private_subnet_1" {
  value = element(aws_subnet.private_subnet.*.id, 1)
}

output "private_subnet_2" {
  value = element(aws_subnet.private_subnet.*.id, 2)
}

