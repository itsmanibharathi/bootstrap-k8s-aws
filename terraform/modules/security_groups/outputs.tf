output "jumpbox_sg_id" {
  value = aws_security_group.jumpbox.id
}

output "control_plane_sg_id" {
  value = aws_security_group.control_plane.id
}

output "worker_sg_id" {
  value = aws_security_group.worker.id
}


