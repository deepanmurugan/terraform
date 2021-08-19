resource "random_id" "random_id_prefix" {
  byte_length = 2
}

module "pretask_networking" {
  default_tags         = var.default_tags
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  availability_zones   = var.availability_zones
  source               = "./modules/pretask_networking"
}

module "networking" {
  default_tags           = var.default_tags
  vpc_id                 = module.pretask_networking.vpc_id
  public_subnet_id_list  = module.pretask_networking.subnet_id
  private_subnet_id_list = module.pretask_networking.private_subnet_id
  availability_zones     = var.availability_zones
  source                 = "./modules/networking"
}

module "frontend_loadbalancer" {
  default_tags                     = var.default_tags
  vpc_id                           = module.pretask_networking.vpc_id
  public_subnet_id                 = module.networking.public_lb_subnet_id
  internal                         = var.internal
  lb_type                          = var.lb_type
  security_groups                  = var.security_groups
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  delete_protection                = var.delete_protection
  enable_http_to_https_redirect    = var.enable_http_to_https_redirect
  from_port                        = var.from_port
  to_port                          = var.to_port
  from_protocol                    = var.from_protocol
  to_protocol                      = var.to_protocol
  description                      = var.description
  target_instance_id               = module.instances.aws_instance_id
  source                           = "./modules/frontend_loadbalancer"
}

module "instances" {
  default_tags            = var.default_tags
  vpc_id                  = module.pretask_networking.vpc_id
  custom_ami              = var.custom_ami
  instance_type           = var.instance_type
  to_port                 = var.to_port
  disable_api_termination = var.disable_api_termination
  private_subnet_id       = module.pretask_networking.private_subnet_id
  lb_security_group       = module.frontend_loadbalancer.security_group_id
  tenancy                 = var.tenancy
  volume_size             = var.volume_size
  volume_type             = var.volume_type
  public_key              = var.public_key
  source                  = "./modules/backend_instances"
}