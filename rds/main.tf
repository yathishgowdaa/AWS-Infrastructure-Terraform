resource "aws_db_instance" "infra_sql" {
  instance_class          = var.db_instance
  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = true
  storage_type            = "gp2"
  allocated_storage       = 20
  name                    = "mytestrds"
  username                = "admin"
  password                = "admin123"
  apply_immediately       = "true"
  backup_retention_period = 10
  backup_window           = "09:46-10:16"
  db_subnet_group_name    = aws_db_subnet_group.rds_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [var.private_subnets[0], var.private_subnets[1]]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "rds_sg_rule" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  to_port           = 3306
  type              = "ingress"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = var.asg_security_group
}

resource "aws_security_group_rule" "outbound_rule" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


