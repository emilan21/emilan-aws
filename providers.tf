terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias   = "prod"
  region  = "us-east-1"
  profile = "Production-Account.Developer"
}

# Configure the archive Provider
provider "archive" {
  alias = "prod"
}
