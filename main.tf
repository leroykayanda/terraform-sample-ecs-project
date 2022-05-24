terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-vpc"
  cidr = "172.17.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["172.17.1.0/24", "172.17.2.0/24"]
  public_subnets  = ["172.17.3.0/24", "172.17.4.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

}


module "ecsModule" {
  source                            = "leroykayanda/ecsModule/aws"
  version                           = "1.0.2"
  env                               = var.env
  region                            = var.region
  cluster_name                      = "${var.env}-${var.cluster_name}"
  service_name                      = "${var.env}-${var.microservice_name}"
  task_execution_role               = aws_iam_role.ExecutionRole.arn
  launch_type                       = "FARGATE"
  fargate_cpu                       = var.fargate_cpu
  fargate_mem                       = var.fargate_mem
  container_name                    = var.container_name
  container_image                   = var.container_image
  task_environment_variables        = []
  task_secret_environment_variables = []
  desired_count                     = var.desired_count
  task_subnets                      = module.vpc.private_subnets
  container_port                    = var.container_port
  vpc_cidr                          = module.vpc.vpc_cidr_block
  vpc_id                            = module.vpc.vpc_id
  alb_access_log_bucket             = aws_s3_bucket.alb_access_logs.bucket
  alb_public_subnets                = module.vpc.public_subnets
  deregistration_delay              = var.deregistration_delay
  min_capacity                      = var.min_capacity
  max_capacity                      = var.max_capacity
  certificate_arn                   = var.certificate_arn
  zone_id                           = var.zone_id
  domain_name                       = var.domain_name
  internal                          = var.internal
  waf                               = var.waf
  health_check_path                 = var.health_check_path
  sns_topic                         = var.sns_topic
}

resource "aws_iam_role" "ExecutionRole" {
  name = "${var.env}-${var.microservice_name}-Task-Execution-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment_AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.ExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_s3_bucket" "alb_access_logs" {
  bucket        = "${var.env}-cbhbchrbcrfg-${var.microservice_name}-alb-access-logs"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id

  rule {
    expiration {
      days = 365
    }
    status = "Enabled"
    id     = "expire-logs"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.alb_access_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_access_log_bucket" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_logs_bucket" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "access_log_bucket_policy" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.alb_access_logs.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.alb_access_logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.alb_access_logs.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
