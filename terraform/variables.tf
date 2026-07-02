# --------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-2"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for the data lakehouse"
  type        = string
  default     = "project-ecommerce-lakehouse"
}

variable "snowflake_storage_integration_arn" {
  description = "ARN of the Snowflake user that will assume the IAM role (from DESCRIBE INTEGRATION in Snowflake)"
  type        = string
  sensitive   = true
}

variable "snowflake_external_id" {
  description = "External ID for the Snowflake storage integration trust policy (from DESCRIBE INTEGRATION in Snowflake)"
  type        = string
  sensitive   = true
}

variable "medallion_layers" {
  description = "List of medallion architecture layer prefixes to create in S3"
  type        = list(string)
  default     = ["bronze", "silver", "gold"]
}
