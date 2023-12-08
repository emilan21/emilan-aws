# Website 1 Account
resource "aws_cloudfront_distribution" "eric_milan_dev" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.eric_milan_dev.website_endpoint
    origin_id   = aws_s3_bucket.eric_milan_dev.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.eric_milan_dev.bucket_regional_domain_name
  }
}

output "website1_cloudfront_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.eric_milan_dev.domain_name
}

# Prod Account
resource "aws_cloudfront_distribution" "eric_milan_dev_prod" {
  provider        = aws.prod
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.eric_milan_dev_prod.website_endpoint
    origin_id   = aws_s3_bucket.eric_milan_dev_prod.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.eric_milan_dev_prod.bucket_regional_domain_name
  }
}

output "prod_cloudfront_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.eric_milan_dev_prod.domain_name
}
