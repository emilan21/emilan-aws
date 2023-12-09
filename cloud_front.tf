# Local
locals {
  s3_origin_id_prod   = "${var.s3_name_prod}-origin"
  s3_domain_name_prod = "${var.s3_name_prod}.s3-website-${var.region}.amazonaws.com"
}

# Prod Account
resource "aws_cloudfront_distribution" "eric_milan_dev_prod" {
  provider = aws.prod

  enabled = true

  origin {
    domain_name = local.s3_domain_name_prod
    origin_id   = local.s3_origin_id_prod
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {

    target_origin_id = local.s3_origin_id_prod
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["ericmilan.dev", "www.ericmilan.dev"]


  price_class = "PriceClass_200"

  tags = {
    Environment = "prod"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.eric_milan_dev_prod.arn
    ssl_support_method             = "sni-only"
  }
}

output "prod_cloudfront_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.eric_milan_dev_prod.domain_name
}
