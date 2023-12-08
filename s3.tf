# Website1 Account 
resource "aws_s3_bucket" "eric_milan_dev" {
  bucket = "eric-milan-dev"
  tags = {
    Name = "ericmilan.dev"
  }
}

resource "aws_s3_bucket_website_configuration" "eric_milan_dev" {
  bucket = aws_s3_bucket.eric_milan_dev.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "eric_milan_dev" {
  bucket = aws_s3_bucket.eric_milan_dev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "eric_milan_dev" {
  bucket = aws_s3_bucket.eric_milan_dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "eric_milan_dev" {
  depends_on = [
    aws_s3_bucket_ownership_controls.eric_milan_dev,
    aws_s3_bucket_public_access_block.eric_milan_dev,
  ]

  bucket = aws_s3_bucket.eric_milan_dev.id
  acl    = "public-read"
}

output "end_point_url" {
  value = aws_s3_bucket_website_configuration.eric_milan_dev.website_endpoint
}

output "web_site_domain" {
  value = aws_s3_bucket_website_configuration.eric_milan_dev.website_domain
}

# Prod account
resource "aws_s3_bucket" "eric_milan_dev_prod" {
  provider = aws.prod
  bucket   = "eric-milan-dev-prod"
  tags = {
    Name = "ericmilan.dev"
  }
}

resource "aws_s3_bucket_website_configuration" "eric_milan_dev_prod" {
  provider = aws.prod
  bucket   = aws_s3_bucket.eric_milan_dev_prod.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "eric_milan_dev_prod" {
  provider = aws.prod
  bucket   = aws_s3_bucket.eric_milan_dev_prod.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "eric_milan_dev_prod" {
  provider = aws.prod
  bucket   = aws_s3_bucket.eric_milan_dev_prod.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "eric_milan_dev_prod" {
  provider = aws.prod
  depends_on = [
    aws_s3_bucket_ownership_controls.eric_milan_dev_prod,
    aws_s3_bucket_public_access_block.eric_milan_dev_prod,
  ]

  bucket = aws_s3_bucket.eric_milan_dev_prod.id
  acl    = "public-read"
}

output "end_point_url" {
  value = aws_s3_bucket_website_configuration.eric_milan_dev_prod.website_endpoint
}

output "web_site_domain" {
  value = aws_s3_bucket_website_configuration.eric_milan_dev_prod.website_domain
}
