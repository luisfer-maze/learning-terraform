terraform {
  required_version = ">=1.4.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}
