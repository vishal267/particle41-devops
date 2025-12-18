# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  # Cluster endpoint settings
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Encryption
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  # IAM role configuration
  create_cluster_security_group = true
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description              = "Nodes on ephemeral ports"
      protocol                 = "tcp"
      from_port                = 1025
      to_port                  = 65535
      type                     = "ingress"
      source_security_group_id = aws_security_group.node_security_group.id
    }
    ingress_alb_https = {
      description              = "ALB HTTPS"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.alb_security_group.id
    }
  }

  # Node group configuration
  eks_managed_node_groups = {
    primary = {
      name            = "${var.cluster_name}-primary"
      use_name_prefix = true
      capacity_type   = "ON_DEMAND"

      instance_types = var.node_instance_types

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.desired_nodes

      # Force nodes to private subnets only
      subnet_ids = module.vpc.private_subnets

      # Disk configuration
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_root_volume_size
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }

      tags = {
        "NodeGroup" = "Primary"
      }
    }
  }

  manage_aws_auth_configmap = true

  tags = {
    Cluster = var.cluster_name
  }
}
