module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "subnets" {
  source               = "./modules/subnets"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "security_groups" {
  source               = "./modules/security_groups"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  jumpbox_ssh_cidr     = var.jumpbox_ssh_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ec2_instances" {
  source                     = "./modules/ec2_instances"
  project_name               = var.project_name
  public_subnet_id           = module.subnets.public_subnet_id
  private_subnet_ids         = module.subnets.private_subnet_ids
  jumpbox_sg_id              = module.security_groups.jumpbox_sg_id
  control_plane_sg_id        = module.security_groups.control_plane_sg_id
  worker_sg_id               = module.security_groups.worker_sg_id
  jumpbox_key_path           = var.jumpbox_key_path
  controlplane_key_path      = var.controlplane_key_path
  workernode_key_path        = var.workernode_key_path
  jumpbox_instance_type      = var.jumpbox_instance_type
  controlplane_instance_type = var.controlplane_instance_type
  workernode_instance_type   = var.workernode_instance_type
  worker_count               = var.worker_count
}

# module "nlb" {
#   source                     = "./modules/nlb"
#   project_name               = var.project_name
#   vpc_id                     = module.vpc.vpc_id
#   private_subnet_ids         = module.subnets.private_subnet_ids
#   control_plane_instance_ids = module.ec2_instances.control_plane_instance_ids
# }


