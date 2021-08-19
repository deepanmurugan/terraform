resource "aws_lb" "load_balancer" {
  name                             = lookup(var.default_tags, "AppName", "Provide Proper Key")
  internal                         = var.internal
  load_balancer_type               = var.lb_type
  security_groups                  = [aws_security_group.security_group_main.id]
  subnets                          = var.public_subnet_id
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.delete_protection

  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-LoadBalancer"
    },
  )
}

resource "aws_lb_listener" "frontend_http_to_https_redirect" {
  count             = var.enable_http_to_https_redirect ? 1 : 0
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.from_port
  protocol          = var.from_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = var.to_port
      protocol    = var.to_protocol
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end" {
  count             = var.enable_http_to_https_redirect ? 0 : 1
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.to_port
  protocol          = var.to_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end_tg[0].arn
  }
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-Listener"
    },
  )
}

resource "aws_lb_target_group" "front_end_tg" {
  count    = var.enable_http_to_https_redirect ? 0 : 1
  name     = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-tg"
  port     = var.to_port
  protocol = var.to_protocol
  vpc_id   = var.vpc_id
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-TargetGroup"
    },
  )
}

resource "aws_lb_target_group_attachment" "front_end_tg_attachment" {
  count            = length(var.target_instance_id)
  target_group_arn = aws_lb_target_group.front_end_tg[0].arn
  target_id        = element(var.target_instance_id, count.index)
  port             = var.to_port
}

resource "aws_security_group" "security_group_main" {
  name_prefix = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-sg"
    },
  )
}

resource "aws_security_group_rule" "allow_ingress_port_from_port" {
  count             = var.lb_type == "application" && var.enable_http_to_https_redirect ? 1 : 0
  type              = "ingress"
  from_port         = var.from_port
  to_port           = var.from_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_main.id
}

resource "aws_security_group_rule" "allow_ingress_port_to_port" {
  type              = "ingress"
  from_port         = var.to_port
  to_port           = var.to_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_main.id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.security_group_main.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}