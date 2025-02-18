

module "ecs_cluster" {


  # create  = false
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  cluster_name = "${var.project}-${var.env}-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
  }



  tags = {
    Environment = var.env
    Project     = var.project
  }
}


module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"

  # create = false
  name        = "${var.project}-${var.env}-frontend"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  subnet_ids = module.vpc.private_subnets
  container_definitions = {

    "${var.project}-${var.env}-frontend-container" = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = "nginx:latest"
      port_mappings = [
        {
          name          = "${var.project}-frontend-3000-http"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem  = false
      enable_cloudwatch_logging = false
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex-ip"].arn
      container_name   = "${var.project}-${var.env}-frontend-container"
      container_port   = 3000
    }
  }

  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}