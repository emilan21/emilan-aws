resource "aws_dynamodb_table" "eric_milan_dev_prod_dynamodb_table" {
  name         = "visit-count-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "prod"
  }
}
