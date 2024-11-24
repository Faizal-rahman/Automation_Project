terraform {
  backend "s3" {
    bucket = "reham-prod-project"           // Bucket where to SAVE Terraform State
    key    = "webservers/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                    // Region where bucket is created
  }
}