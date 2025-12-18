variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-app"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-app-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "node_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_root_volume_size" {
  description = "Root volume size for nodes in GB"
  type        = number
  default     = 30
}

# ACME & SSL Certificate Variables
variable "acme_server_url" {
  description = "ACME server URL (Let's Encrypt)"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  # For testing/staging use: "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "acme_email" {
  description = "Email address for ACME registration and certificate notifications"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the certificate (e.g., example.com)"
  type        = string
}

variable "subject_alternative_names" {
  description = "Alternative domain names for the certificate"
  type        = list(string)
  default     = []
}

variable "enable_www_redirect" {
  description = "Enable www subdomain redirect to main domain"
  type        = bool
  default     = true
}
