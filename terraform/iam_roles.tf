locals {
  # Bootstrap logic: If snowflake_iam_user_arn is empty, trust the current caller to allow initial creation.
  snowflake_principal = var.snowflake_iam_user_arn == "" ? data.aws_caller_identity.current.arn : var.snowflake_iam_user_arn
}

resource "aws_iam_policy" "lakehouse_rw_policy" {
    name = "LakehouseReadWritePolicy"
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
                    "s3:ListBucket"
                ]
                Resource = [
                    "${aws_s3_bucket.data_lake.arn}/*",
                    aws_s3_bucket.data_lake.arn
                ]
            }
        ]
    })
}

resource "aws_iam_role" "snowflake_role" {
  name = "SnowflakeStorageIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = local.snowflake_principal
        }
        Condition = {
          StringEquals = {
            # Only enforce ExternalId if we are using the real Snowflake Principal
            "sts:ExternalId" = var.snowflake_external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_s3_attachment" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.lakehouse_rw_policy.arn
}
