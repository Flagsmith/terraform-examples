data "aws_route53_zone" "selected" {
  name         = var.route53_hosted_zone
  private_zone = false
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.app_name}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs-alb.dns_name
    zone_id                = aws_lb.ecs-alb.zone_id
    evaluate_target_health = true
  }

}
