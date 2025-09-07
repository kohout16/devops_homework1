# KMS Key for encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for DevOps Lesson 13 encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Cloudwatch Logs to use the key"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Describe*"
        ]
        Resource = "*"
      },

      {
        Sid    = "Allow use of the key for RDS"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key for Lambda"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "devops-lesson-13-kms-key"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# S3 Bucket
resource "aws_s3_bucket" "devops_lesson" {
  bucket = "devops-lesson-13-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "devops-lesson-13-bucket"
  }
}

# Default encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "devops_lesson" {
  bucket = aws_s3_bucket.devops_lesson.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

# enforce encryption policy (extra homework)
resource "aws_s3_bucket_policy" "devops_lesson" {
  bucket = aws_s3_bucket.devops_lesson.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PutObjPolicy",
    Statement = [
      {
        Sid       = "DenyIncorrectEncryptionHeader"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.devops_lesson.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.devops_lesson.arn}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = true
          }
        }
      },
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.devops_lesson.arn,
          "${aws_s3_bucket.devops_lesson.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
