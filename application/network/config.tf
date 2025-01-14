terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "group4seneca"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
