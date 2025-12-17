# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "${var.cluster_name}-key"
  }
}

# KMS Key Alias
resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}
