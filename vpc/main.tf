data "aws_availability_zones" "available" {}


resource "aws_vpc" "infra_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-terraform-vpc"
    Env  = "test"
  }
}



resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.infra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra_gw.id
  }

  tags = {
    Name = "test-public-route"
    Env  = "Env"
  }
}


resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.infra_vpc.default_route_table_id

  route {
    nat_gateway_id = aws_nat_gateway.infra_ng.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "private-route-table"
  }
}


resource "aws_internet_gateway" "infra_gw" {
  vpc_id = aws_vpc.infra_vpc.id

  tags = {
    Name = "test-igw"
  }
}


resource "aws_eip" "infra_eip" {
  vpc = true
}


resource "aws_nat_gateway" "infra_ng" {
  allocation_id = aws_eip.infra_eip.id
  subnet_id     = aws_subnet.public_subnet.0.id
  tags = {
    Name = "test-ngw"
  }
}



resource "aws_subnet" "public_subnet" {
  count                   = 2
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.infra_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "test-public-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count             = 2
  cidr_block        = var.private_cidrs[count.index]
  vpc_id            = aws_vpc.infra_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "test-private-subnet-${count.index + 1}"
  }
}


resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  depends_on     = [aws_route_table.public_route, aws_subnet.public_subnet]
}


resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  route_table_id = aws_default_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  depends_on     = [aws_default_route_table.private_route, aws_subnet.private_subnet]
}


resource "aws_security_group" "infra_sg" {
  name   = "test-sg"
  vpc_id = aws_vpc.infra_vpc.id
}


resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.infra_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.infra_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.infra_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


