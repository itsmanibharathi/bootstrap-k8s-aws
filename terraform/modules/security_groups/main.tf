resource "aws_security_group" "jumpbox" {
  name        = "${var.project_name}-jumpbox-sg"
  description = "Security group for jumpbox"
  vpc_id      = var.vpc_id

  # Ingress (ALLOW ALL — consider tightening this!)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (ALLOW ALL)tf
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-jumpbox-sg", Role = "jumpbox" })
}

resource "aws_security_group" "control_plane" {
  name        = "${var.project_name}-control-plane-sg"
  description = "Security group for control plane nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-control-plane-sg", Role = "control-plane" })
}

resource "aws_security_group" "worker" {
  name        = "${var.project_name}-worker-sg"
  description = "Security group for worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-worker-sg", Role = "worker" })
}

# # SSH from Jumpbox to Control Plane
# resource "aws_security_group_rule" "cp_ssh_from_jumpbox" {
#   type                     = "ingress"
#   from_port                = 22
#   to_port                  = 22
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.control_plane.id
#   source_security_group_id = aws_security_group.jumpbox.id
# }

# # kube-apiserver 6443 from NLB (approximate by allowing from private subnets where NLB is placed)
# resource "aws_security_group_rule" "cp_apiserver_from_nlb_subnets" {
#   type              = "ingress"
#   from_port         = 6443
#   to_port           = 6443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.control_plane.id
#   cidr_blocks       = var.private_subnet_cidrs
# }

# # etcd peer ports between control plane nodes
# resource "aws_security_group_rule" "cp_etcd_2379" {
#   type                     = "ingress"
#   from_port                = 2379
#   to_port                  = 2379
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.control_plane.id
#   source_security_group_id = aws_security_group.control_plane.id
# }

# resource "aws_security_group_rule" "cp_etcd_2380" {
#   type                     = "ingress"
#   from_port                = 2380
#   to_port                  = 2380
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.control_plane.id
#   source_security_group_id = aws_security_group.control_plane.id
# }

# # kubelet on control plane from control plane and jumpbox
# resource "aws_security_group_rule" "cp_kubelet_from_cp" {
#   type                     = "ingress"
#   from_port                = 10250
#   to_port                  = 10250
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.control_plane.id
#   source_security_group_id = aws_security_group.control_plane.id
# }

# resource "aws_security_group_rule" "cp_kubelet_from_jumpbox" {
#   type                     = "ingress"
#   from_port                = 10250
#   to_port                  = 10250
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.control_plane.id
#   source_security_group_id = aws_security_group.jumpbox.id
# }

# # SSH from Jumpbox to Workers
# resource "aws_security_group_rule" "worker_ssh_from_jumpbox" {
#   type                     = "ingress"
#   from_port                = 22
#   to_port                  = 22
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.worker.id
#   source_security_group_id = aws_security_group.jumpbox.id
# }

# # kubelet on workers from control plane
# resource "aws_security_group_rule" "worker_kubelet_from_cp" {
#   type                     = "ingress"
#   from_port                = 10250
#   to_port                  = 10250
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.worker.id
#   source_security_group_id = aws_security_group.control_plane.id
# }

