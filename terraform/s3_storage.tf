resource "aws_s3_bucket" "data_lake" {
    bucket = var.lakehouse_bucket_name
    force_destroy = true
}

resource "aws_s3_object" "bronze_layer" {
    bucket = aws_s3_bucket.data_lake.id
    key = "bronze/"
}

resource "aws_s3_object" "silver_layer" {
    bucket = aws_s3_bucket.data_lake.id
    key = "silver/"
}

resource "aws_s3_object" "gold_layer" {
    bucket = aws_s3_bucket.data_lake.id
    key = "gold/"
}

resource "aws_s3_bucket_public_access_block" "data_lake_privacy" {
    depends_on = [aws_s3_bucket.data_lake]
    bucket = aws_s3_bucket.data_lake.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}
