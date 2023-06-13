data "aws_acm_certificate" "certificate" {
  domain   = "*.${data.aws_route53_zone.selected.name}"
  statuses = ["ISSUED"]
}

# Load Balancer
resource "aws_lb" "ecs-alb" {
  name               = "${local.ecs_cluster_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = module.vpc.public_subnets
}

# Target group
resource "aws_alb_target_group" "default-target-group" {
  name        = "${var.app_environment}-${var.app_name}-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

# Listener, redirects HTTP to HTTPS
resource "aws_alb_listener" "ecs-alb-http-listener" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener (redirects traffic from the load balancer to the target group)
# Check for latest  ssl policy https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
resource "aws_alb_listener" "ecs-alb-https-listener" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.certificate.arn
  depends_on        = [aws_alb_target_group.default-target-group]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Bad Request"
      status_code  = "400"
    }
  }

}
# matches header with configured flagsmith subdomain
resource "aws_alb_listener_rule" "host_header" {
  listener_arn = aws_alb_listener.ecs-alb-https-listener.arn
  priority     = 10

  condition {
    host_header {
      values = ["${var.app_name}.${data.aws_route53_zone.selected.name}"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default-target-group.arn
  }
}