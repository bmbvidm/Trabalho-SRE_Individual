variable "aws_region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para organização de tags."
  type        = string
  default     = "lambda-sqs-api"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)."
  type        = string
  default     = "dev"
}
