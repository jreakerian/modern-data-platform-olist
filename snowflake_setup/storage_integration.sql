CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::875388088287:role/SnowflakeStorageIntegrationRole'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://project-ecommerce-lakehouse/bronze/', 's3://project-ecommerce-lakehouse/silver/', 's3://project-ecommerce-lakehouse/gold/')
