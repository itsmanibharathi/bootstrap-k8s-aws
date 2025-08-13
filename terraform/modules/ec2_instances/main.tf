resource "aws_key_pair" "jumpbox_key" {
  key_name   = "${var.project_name}-jumpbox-key"
  public_key = file(var.jumpbox_key_path)

}
resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.jumpbox_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.jumpbox_sg_id]
  key_name                    = aws_key_pair.jumpbox_key.key_name
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

resource "aws_key_pair" "controlplane_key" {
  key_name   = "${var.project_name}-controlplane-key"
  public_key = file(var.controlplane_key_path)
}


resource "aws_instance" "control_plane" {
  count                       = length(var.private_subnet_ids)
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.controlplane_instance_type
  subnet_id                   = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids      = [var.control_plane_sg_id]
  key_name                    = aws_key_pair.controlplane_key.key_name
  associate_public_ip_address = false

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname      = "${var.project_name}-cp-${count.index + 1}"
    instance_name = "${var.project_name}-cp-${count.index + 1}"
    project_name  = var.project_name
    worker_count  = var.worker_count
  }))
  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cp-${count.index + 1}"
      Role = "control-plane"
    }
  )
}

resource "aws_key_pair" "workernode_key" {
  key_name   = "${var.project_name}-workernode-key"
  public_key = file(var.workernode_key_path)
}

resource "aws_instance" "worker" {
  count                       = var.worker_count
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.workernode_instance_type
  subnet_id                   = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids      = [var.worker_sg_id]
  key_name                    = aws_key_pair.workernode_key.key_name
  associate_public_ip_address = false

  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname      = "${var.project_name}-worker-${count.index + 1}"
    instance_name = "${var.project_name}-worker-${count.index + 1}"
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
