module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.13.0"


  # create = false
  name = "${var.project}-${var.env}-alb"

  enable_deletion_protection = false

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  listeners = {
    # ex-http-https-redirect = {
    #   port     = 80
    #   protocol = "HTTP"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    # }
    # ex-https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

    #   forward = {
    #     target_group_key = "ex-ip"
    #   }
    # }

    ex-http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex-ip"
      }
    }
  }

  target_groups = {
    ex-ip = {
      protocol          = "HTTP"
      port              = 3000
      target_type       = "ip"
      create_attachment = false


      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
    }
  }

  #   target_groups = [
  #     {
  #       name             = "${local.name}-${local.container_name}"
  #       backend_protocol = "HTTP"
  #       backend_port     = local.container_port
  #       target_type      = "ip"
  #     },
  #   ]

}