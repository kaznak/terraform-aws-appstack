# -*- Mode: HCL; -*-

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    # type             = "forward"
    target_group_arn = local.active_target_groups.service.arn

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = local.listener_certs[0]

  default_action {
    type             = "forward"
    target_group_arn = local.active_target_groups.service.arn
  }
}

resource "aws_lb_listener_certificate" "main" {
  count           = length(local.listener_certs) - 1
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn   = local.listener_certs[count.index + 1]
}
