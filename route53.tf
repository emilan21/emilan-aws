locals {
  MXRecordSets = {
    "@" = {
      Type = "MX",
      TTL  = 3600,
      MXRecords = [
        {
          "Value" = "10 mx1.privateemail.com"
        },
        {
          "Value" = "10 mx2.privateemail.com"
        }
      ]
    }
  }
  TXTRecordSets = {
    "@" = {
      Type = "TXT",
      TTL  = 3600,
      TXTRecords = [
        {
          "Value" = "v=spf1 include:spf.privateemail.com ~all"
        }
      ]
    }
  }
}

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
  provider = aws.prod
  zone_id  = aws_route53_zone.eric_milan_dev_prod.zone_id
  name     = "ericmilan.dev"
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.eric_milan_dev_prod.domain_name
    zone_id                = aws_cloudfront_distribution.eric_milan_dev_prod.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mx_records" {
  provider = aws.prod
  for_each = local.MXRecordSets
  zone_id  = aws_route53_zone.eric_milan_dev_prod.id
  name     = each.key
  type     = each.value.Type
  records  = [for key, record in each.value["MXRecords"] : record["Value"]]
  ttl      = 1
}

resource "aws_route53_record" "txt_records" {
  provider = aws.prod
  for_each = local.TXTRecordSets
  zone_id  = aws_route53_zone.eric_milan_dev_prod.id
  name     = each.key
  type     = each.value.Type
  records  = [for key, record in each.value["TXTRecords"] : record["Value"]]
  ttl      = 1
}
