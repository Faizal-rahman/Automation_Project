output "vpc_id" {

  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "public_route_tables" {
  value = module.vpc.public_route_tables
}

output "private_route_tables" {
  value = module.vpc.private_route_tables
  }