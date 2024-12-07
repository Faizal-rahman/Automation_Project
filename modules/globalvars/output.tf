output "default_tags" {
  value = {
    "Owner" = "GroupFour"
    "App"   = "Web"
  }
}

output "prefix" {
  value = "project"
}

output "s3_dev_backend_bucket" {
  value = "reham-dev-project"
}

output "s3_prod_backend_bucket" {
  value = "reham-prod-project"
}

output "s3_staging_backend_bucket" {
  value = "group4seneca"
}