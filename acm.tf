resource "aws_acm_certificate" "eric_milan_dev_prod" {
  private_key       = file("namecheap_ssl/private.key")
  certificate_body  = file("namecheap_ssl/ericmilan_dev.crt")
  certificate_chain = file("namecheap_ssl/ericmilan_dev.ca-bundle")
}
