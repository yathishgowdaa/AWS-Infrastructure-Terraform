provider "aws" {
  region  = "us-west-2"
  version = "~> 3.10.0"
}

module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.1.0.0/16"
  public_cidrs  = ["10.1.1.0/24", "10.1.3.0/24"]
  private_cidrs = ["10.1.2.0/24", "10.1.4.0/24"]
}

module "alb" {
  source         = "./alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "auto_scaling" {
  source               = "./auto_scaling"
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  alb_target_group_arn = module.alb.alb_target_group_arn
}


module "rds" {
  source             = "./rds"
  db_instance        = "db.t2.micro"
  private_subnets    = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  asg_security_group = module.auto_scaling.asg_security_group
}