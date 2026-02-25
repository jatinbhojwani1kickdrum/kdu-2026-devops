locals {
  common_tags = {
    Environment = var.environment
    Creator     = var.creator
    Project     = var.name_prefix
  }
}
resource "aws_lb" "this" {
  name               = "${var.name_prefix}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.environment}-alb"
  })
}

resource "aws_lb_target_group" "backend" {
  name_prefix     = "${var.environment}-be"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "frontend" {
  name_prefix    = "${var.environment}-fe"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = local.common_tags
}
resource "aws_autoscaling_attachment" "backend_attach" {
  autoscaling_group_name = var.app_asg_name
  lb_target_group_arn    = aws_lb_target_group.backend.arn
}


# HTTP Listener (port 80) - default fixed 404
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 - Not Found"
      status_code  = "404"
    }
  }
}

# Rule 1: /addExchangeRate -> backend
resource "aws_lb_listener_rule" "add_exchange_rate" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/addExchangeRate", "/addExchangeRate/*"]
    }
  }
}

# Rule 2: /getTotalCount -> backend
resource "aws_lb_listener_rule" "get_total_count" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/getTotalCount", "/getTotalCount/*"]
    }
  }
}

# Rule 3: /getAmount -> backend
resource "aws_lb_listener_rule" "get_amount" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/getAmount", "/getAmount/*"]
    }
  }
}

# Rule 4: /* -> frontend
resource "aws_lb_listener_rule" "landing_page" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_autoscaling_attachment" "frontend_attach" {
  autoscaling_group_name = var.app_asg_name
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}