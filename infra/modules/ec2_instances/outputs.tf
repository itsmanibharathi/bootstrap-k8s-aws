output "jumpbox_public_ip" {
  value = aws_instance.jumpbox.public_ip
}
output "jumpbox_private_ip" {
  value = aws_instance.jumpbox.private_ip
}

output "control_plane_private_ips" {
  value = [for k in sort(keys(aws_instance.control_plane)) : aws_instance.control_plane[k].private_ip]
}

output "control_plane_instance_ids" {
  value = [for k in sort(keys(aws_instance.control_plane)) : aws_instance.control_plane[k].id]
}

output "control_plane_names" {
  value = [for k in sort(keys(aws_instance.control_plane)) : aws_instance.control_plane[k].tags.Name]
}

output "worker_private_ips" {
  value = [for i in aws_instance.worker : i.private_ip]
}

output "worker_names" {
  value = [for i in aws_instance.worker : i.tags.Name]
}



