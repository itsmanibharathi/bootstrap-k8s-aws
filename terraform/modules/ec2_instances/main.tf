resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.jumpbox_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.jumpbox_sg_id]
  key_name                    = var.jumpbox_key_name
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname      = "${var.project_name}-jumpbox"
    instance_name = "jumpbox"
    project_name  = var.project_name
    worker_count  = var.worker_count
  }))
  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-jumpbox"
      Role = "jumpbox"
    }
  )

}

locals {
  control_plane_nodes = {
    "cp-1" = var.private_subnet_ids[0]
    "cp-2" = var.private_subnet_ids[1]
    "cp-3" = var.private_subnet_ids[2]
  }
}

resource "aws_instance" "control_plane" {
  for_each                    = local.control_plane_nodes
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.controlplane_instance_type
  subnet_id                   = each.value
  vpc_security_group_ids      = [var.control_plane_sg_id]
  key_name                    = var.controlplane_key_name
  associate_public_ip_address = false

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname      = "${var.project_name}-${each.key}"
    instance_name = each.key
    project_name  = var.project_name
    worker_count  = var.worker_count
  }))
  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${each.key}"
      Role = "control-plane"
    }
  )
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.workernode_instance_type
  subnet_id                   = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids      = [var.worker_sg_id]
  key_name                    = var.workernode_key_name
  associate_public_ip_address = false

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname      = "${var.project_name}-worker-${count.index + 1}"
    instance_name = "worker-${count.index + 1}"
    project_name  = var.project_name
    worker_count  = var.worker_count
  }))

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-worker-${count.index + 1}"
      Role = "worker"
    }
  )
}