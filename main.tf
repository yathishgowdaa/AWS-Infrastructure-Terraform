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


