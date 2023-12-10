resource "aws_route53_zone" "eric_milan_dev_prod" {
  provider      = aws.prod
  name          = "ericmilan.dev"
  force_destroy = true
}

output "nameservers" {
  description = "Route 53 Name Servers"
  value       = aws_route53_zone.eric_milan_dev_prod.name_servers
}

resource "aws_route53_record" "eric_milan_dev_prod" {
  zone_id = aws_route53_zone.eric_milan_dev_prod.zone_id
  name    = "ericmilan.dev"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.eric_milan_dev_prod.domain_name
    zone_id                = aws_cloudfront_distribution.eric_milan_dev_prod.hosted_zone_id
    evaluate_target_health = true
  }
}
