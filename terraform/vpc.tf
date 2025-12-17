# VPC Module - Creates 2 public and 2 private subnets across 2 AZs
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  # Get 2 Availability Zones in the region
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # 2 Private Subnets - for EKS nodes only
  # Default: ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets = var.private_subnet_cidrs

  # 2 Public Subnets - for Load Balancer
  # Default: ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = var.public_subnet_cidrs

  # NAT Gateway Configuration
  enable_nat_gateway = true
  single_nat_gateway = false # Creates 1 NAT per AZ for High Availability (2 NATs total)
  enable_vpn_gateway = false

  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Kubernetes-specific tags for ALB discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Type                                        = "Public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Type                                        = "Private"
  }

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
