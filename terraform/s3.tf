# Bucket for Kops Statefiles

resource "aws_s3_bucket" "kops-statefile" {
  bucket = "kopscluster-statefile"
  acl    = "private"

  tags = {
    Name    = "kops-statefile"
    Created = "with Terraform"
  }
}

# Bucket for K8s Pipeline
resource "aws_s3_bucket" "codepipeline-kubernetes" {
  bucket = "codepipeline-kubernetes"
  acl    = "private"

  tags = {
    Name    = "kubernetes-pipeline"
    Created = "with Terraform"
  }
}

# Bucket Policy for K8s Pipeline bucket to ensure a encrpytion

resource "aws_s3_bucket_policy" "codepipeline-kubernetes-bucket-policy" {
  bucket = aws_s3_bucket.codepipeline-kubernetes.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "SSEAndSSLPolicy",
    "Statement": [
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::codepipeline-kubernetes/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyInsecureConnections",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::codepipeline-kubernetes/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}