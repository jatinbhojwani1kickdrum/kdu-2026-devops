module "vpc" {
  source = "../../modules/vpc"

  name_prefix = var.name_prefix
  environment = var.environment
  creator     = var.creator

  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
}


module "security" {
  source = "../../modules/security"

  name_prefix = var.name_prefix
  environment = var.environment
  creator     = var.creator

  vpc_id = module.vpc.vpc_id

  allowed_ssh_cidr = "0.0.0.0/0"
}

module "compute" {
  source = "../../modules/compute"

  name_prefix = var.name_prefix
  environment = var.environment
  creator     = var.creator

  public_subnet_id = module.vpc.public_subnet_ids[0]
  app_subnet_ids   = module.vpc.app_subnet_ids

  bastion_sg_id = module.security.bastion_sg_id
  app_sg_id     = module.security.app_sg_id

  key_name = "jatin-devops-iac2-key"

  db_endpoint = module.database.db_endpoint
  db_username = "admin"
  db_password = var.db_password

  frontend_repo = var.frontend_repo
  backend1_repo = var.backend1_repo
  backend2_repo = var.backend2_repo
}


module "alb" {
  source = "../../modules/alb"

  name_prefix = var.name_prefix
  environment = var.environment
  creator     = var.creator

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  app_asg_name      = module.compute.app_asg_name
}

module "database" {
  source = "../../modules/database"

  name_prefix = var.name_prefix
  environment = var.environment
  creator     = var.creator

  db_subnet_ids = module.vpc.db_subnet_ids
  db_sg_id      = module.security.db_sg_id

  db_name     = "company"
  db_username = "admin"
  db_password = var.db_password
}