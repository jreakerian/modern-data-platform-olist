# --------------------------------------------------------------------------
# Data Sources
# --------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# --------------------------------------------------------------------------
# S3 Bucket — Data Lakehouse
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "data_lake" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }    }
  }
}

# Block all public access to the data lake
resource "aws_s3_bucket_public_access_block" "data_lake_privacy" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------------------------------
# S3 Medallion Layer Folders (bronze / silver / gold)
# --------------------------------------------------------------------------

resource "aws_s3_object" "medallion_layers" {
  for_each = toset(var.medallion_layers)

  bucket = aws_s3_bucket.data_lake.id
  key    = "${each.value}/"
}

# --------------------------------------------------------------------------
# IAM — Snowflake Storage Integration
# --------------------------------------------------------------------------

# Policy granting read/write access to the data lake bucket
resource "aws_iam_policy" "lakehouse_rw_policy" {
  name        = "LakehouseReadWritePolicy"
  description = "Allows read/write to the Medallion buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          "${aws_s3_bucket.data_lake.arn}/*",
          aws_s3_bucket.data_lake.arn,
        ]
      }
    ]
  })
}

# IAM role that Snowflake assumes via storage integration
resource "aws_iam_role" "snowflake_role" {
  name = "SnowflakeStorageIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = var.snowflake_storage_integration_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.snowflake_external_id
          }
        }
      }
    ]
  })
}

# Attach the S3 policy to the Snowflake role
resource "aws_iam_role_policy_attachment" "snowflake_s3_attachment" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.lakehouse_rw_policy.arn
}
