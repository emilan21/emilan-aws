terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "Web-Site-1.Developer"
}

provider "aws" {
  alias   = "prod"
  region  = "us-east-1"
  profile = "Production-Account.Developer"
}
