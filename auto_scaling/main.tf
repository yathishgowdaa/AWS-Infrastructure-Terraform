resource "aws_launch_configuration" "launch_config" {
  image_id        = "ami-01fee56b22f308154"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "infra_asg" {
  launch_configuration = aws_launch_configuration.launch_config.name
  vpc_zone_identifier  = [var.private_subnets[0]]
  target_group_arns    = [var.alb_target_group_arn]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value                = "test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg_sg" {
  name   = "asg-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.asg_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.asg_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.asg_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
