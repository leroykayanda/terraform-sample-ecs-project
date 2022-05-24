variable "env" {
  type        = string
  description = "Deployment environment eg prod, dev"
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "microservice_name" {
  type = string
}

variable "fargate_cpu" {
  type        = number
  description = "Number of cpu units used by a Fargate task"
  default     = 1
}

variable "fargate_mem" {
  type        = number
  description = "Amount (in MiB) of memory used by the task"
  default     = 2048
}

variable "container_name" {
  type        = string
  description = "Name of the container"
}

variable "container_image" {
  type = string
}

variable "desired_count" {
  type        = string
  description = "Desired number of tasks"
}

variable "container_port" {
  type        = number
  description = "Port used by the container to receive traffic"
}

variable "deregistration_delay" {
  type        = number
  description = "ALB target group deregistration delay"
}

variable "internal" {
  type        = string
  description = "Boolean - whether the ALB is internal or not"
}

variable "min_capacity" {
  type        = number
  description = "Minimum no. of tasks"
}

variable "max_capacity" {
  type        = number
  description = "Maximum no. of tasks"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate for the ALB HTTPS listener"
}

variable "zone_id" {
  type        = string
  description = "Hosted Zone ID for the zone you want to create the ALB DNS record in"
}

variable "domain_name" {
  type        = string
  description = "DNS name in your hosted zone that you want to point to the ALB"
}


variable "health_check_path" {
  type        = string
  description = "Health check path"
  default     = "/"
}

variable "waf" {
  type        = string
  description = "Tag used by AWS Firewall manager to determine whether or not to associate a WAF. Value can be yes or no "
  default     = "yes"
}

variable "sns_topic" {
  type        = string
  description = "SNS topic ARN for notifications"
  default     = ""
}



