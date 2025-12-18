# AWS Provider
provider "aws" {
  region = var.aws_region

  # Uncomment the following block to use LocalStack for local testing
   skip_credentials_validation = true
   skip_requesting_account_id  = true
   skip_region_validation      = true
  #
   endpoints {
     ec2             = "http://localhost:4566"
     elbv2           = "http://localhost:4566"
     iam             = "http://localhost:4566"
     eks             = "http://localhost:4566"
     autoscaling     = "http://localhost:4566"
     sts             = "http://localhost:4566"
     kms             = "http://localhost:4566"
   }

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Get cluster auth token
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Note: For ACME/Let's Encrypt with Route53 DNS validation,
# ensure AWS credentials are configured with appropriate IAM permissions.
# Required IAM permissions for Route53 DNS challenge:
# - route53:GetChange
# - route53:ListResourceRecordSets
# - route53:ChangeResourceRecordSets
# - route53:CreateHostedZone (if creating new zone)