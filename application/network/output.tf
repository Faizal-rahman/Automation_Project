output "vpc_id" {
  value = module.vpc_prod.vpc_id
}

output "public_subnet_id" {
  value = module.vpc_prod.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc_prod.private_subnet_id
}

output "public_route_tables" {
  value = module.vpc_prod.public_route_tables
}

output "private_route_tables" {
  value = module.vpc_prod.private_route_tables
}

output "vpc_cidr" {
  value = var.vpc_cidr
}