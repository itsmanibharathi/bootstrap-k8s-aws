resource "aws_lb" "internal_api" {
  name               = "${var.project_name}-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-internal-nlb"
      Role = "control-plane"
    }
  )
}

resource "aws_lb_target_group" "apiserver" {
  name        = "${var.project_name}-apiserver"
  port        = 6443
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = "6443"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-apiserver-tg"
      Role = "control-plane"
    }
  )
}

resource "aws_lb_target_group_attachment" "cp_nodes" {
  count            = length(var.control_plane_instance_ids)
  target_group_arn = aws_lb_target_group.apiserver.arn
  target_id        = var.control_plane_instance_ids[count.index]
  port             = 6443
}

resource "aws_lb_listener" "apiserver" {
  load_balancer_arn = aws_lb.internal_api.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apiserver.arn
  }
}

