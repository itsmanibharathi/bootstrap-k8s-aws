output "jumpbox_public_ip" {
  description = "Public IP address of the Jump Host"
  value       = module.ec2_instances.jumpbox_public_ip
}
output "jumpbox_private_ip" {
  description = "Private IP address of the Jump Host"
  value       = module.ec2_instances.jumpbox_private_ip
}

output "control_plane_private_ips" {
  description = "Private IPs of control plane nodes"
  value       = module.ec2_instances.control_plane_private_ips
}
# control plane name
output "control_plane_names" {
  description = "Names of control plane nodes"
  value       = module.ec2_instances.control_plane_names
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = module.ec2_instances.worker_private_ips
}

# worker name
output "worker_names" {
  description = "Names of worker nodes"
  value       = module.ec2_instances.worker_names
}


output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.subnets.public_subnet_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.subnets.private_subnet_ids
}

# output "nlb_dns_name" {
#   description = "Internal NLB DNS name for kube-apiserver"
#   value       = module.nlb.nlb_dns_name
# }


