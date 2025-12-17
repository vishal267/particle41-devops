provider "acme" {
  server_url = var.acme_server_url
}

# Generate a private key for the certificate
resource "tls_private_key" "cert" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an ACME registration
resource "acme_registration" "reg" {
  account_key_pem      = tls_private_key.cert.private_key_pem
  email_address        = var.acme_email
}

# Request a certificate from Let's Encrypt
resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  dns_challenge {
    provider = "route53"
    config = {
      AWS_HOSTED_ZONE_ID          = aws_route53_zone.main.zone_id
      AWS_DNS_PROPAGATION_TIMEOUT = "180"
    }
  }

  depends_on = [acme_registration.reg]

  lifecycle {
    create_before_destroy = true
  }
}

# Store certificate in ACM
resource "aws_acm_certificate" "cert" {
  private_key       = acme_certificate.cert.private_key_pem
  certificate_body  = acme_certificate.cert.certificate_pem
  certificate_chain = acme_certificate.cert.issuer_pem

  tags = {
    Name = "${var.cluster_name}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 Hosted Zone for domain
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.cluster_name}-zone"
  }
}

# Route53 Record for ALB
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# Optional: Route53 CNAME for www subdomain
resource "aws_route53_record" "alb_www" {
  count   = var.enable_www_redirect ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_route53_zone.main.name]
}

# Outputs for certificate details
output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "route53_nameservers" {
  description = "Route53 nameservers for domain delegation"
  value       = aws_route53_zone.main.name_servers
}

output "domain_url" {
  description = "Domain URL"
  value       = "https://${var.domain_name}"
}
