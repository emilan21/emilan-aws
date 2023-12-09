# Website1 Account
resource "aws_acm_certificate" "eric_milan_dev" {
  domain_name       = "dev.eric_milan.dev"
  validation_method = "DNS"
}

data "aws_route53_zone" "eric_milan_dev" {
  name         = "eric_milan_dev"
  private_zone = false
}

resource "aws_route53_record" "eric_milan_dev" {
  for_each = {
    for dvo in aws_acm_certificate.eric_milan_dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.eric_milan_dev.zone_id
}

resource "aws_acm_certificate_validation" "eric_milan_dev" {
  certificate_arn         = aws_acm_certificate.eric_milan_dev.arn
  validation_record_fqdns = [for record in aws_route53_record.eric_milan_dev : record.fqdn]
}

# Prod Account
resource "aws_acm_certificate" "eric_milan_dev_prod" {
  domain_name       = "dev.eric_milan.dev"
  validation_method = "DNS"
}

data "aws_route53_zone" "eric_milan_dev_prod" {
  name         = "eric_milan_dev_prod"
  private_zone = false
}

resource "aws_route53_record" "eric_milan_dev_prod" {
  for_each = {
    for dvo in aws_acm_certificate.eric_milan_dev_prod.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.eric_milan_dev_prod.zone_id
}

resource "aws_acm_certificate_validation" "eric_milan_dev_prod" {
  certificate_arn         = aws_acm_certificate.eric_milan_dev_prod.arn
  validation_record_fqdns = [for record in aws_route53_record.eric_milan_dev_prod : record.fqdn]
}
