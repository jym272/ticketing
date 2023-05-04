variable "cluster" {
  type = object({
    prefix_name = string
  })
  description = "EKS Cluster for ticketing microservices"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  type        = string
  description = "Stage for the deployment"
}

