aws_region         = "us-east-1"
environment        = "prod"
project_name       = "my-app"
cluster_name       = "my-app-eks"
kubernetes_version = "1.27"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# EKS Node Configuration
node_instance_types   = ["t3.medium"]
min_nodes             = 2
max_nodes             = 4
desired_nodes         = 2
node_root_volume_size = 30

# ACME & SSL Certificate Configuration
acme_server_url           = "https://acme-v02.api.letsencrypt.org/directory" # Let's Encrypt Production
acme_email                = "admin@particle41.com"                           # Change to your email
domain_name               = "particle41.com"                                 # Change to your domain
subject_alternative_names = ["app.particle41.com"]                           # Optional SANs
enable_www_redirect       = true                                             # Enable www redirect
