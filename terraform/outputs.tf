# --------------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------------

output "s3_bucket_name" {
  description = "Name of the data lakehouse S3 bucket"
  value       = aws_s3_bucket.data_lake.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the data lakehouse S3 bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "snowflake_integration_role_arn" {
  description = "ARN of the IAM role for Snowflake storage integration — use this in CREATE STORAGE INTEGRATION"
  value       = aws_iam_role.snowflake_role.arn
}
