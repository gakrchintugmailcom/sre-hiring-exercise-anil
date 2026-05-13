variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "ozltd-api"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}
