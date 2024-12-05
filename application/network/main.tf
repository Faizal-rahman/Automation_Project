module "globalvars" {
  source = "../../modules/globalvars"
}

module "vpc" {
  source = var.environment == "prod" ? "./modules/vpc_prod" : "./modules/vpc_stage"
}

  source                     = "../../modules/network"
  vpc_cidr                   = var.vpc_cidr
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  default_tags               = module.globalvars.default_tags
  env                        = var.env
  prefix                     = module.globalvars.prefix
  nat_gateway                = true
  internet_gateway           = true
}

provider "aws" {
  region  = "us-east-1"
  access_key = "ASIAXHSQPKZ7UYWMDBFH"
  secret_key = "4jI6/I1PYISCEvBcVNPl0kg2U5Oumtw3e2c5VgOY"
  token      = "IQoJb3JpZ2luX2VjEGEaCXVzLXdlc3QtMiJGMEQCIBpVbpgSyGK3mFJ52ckF5Pg+UkydgMXS2wO+dqf8th7vAiAnWFEoU2+f0L/BpCEzZx9mGsLJ5yZfj4IU4EFx9oqXuiquAggaEAAaDDQ5NzMxMTI0MTg1NSIM0YCMzlhRjSLsxMtBKosCIYc1HdRGbcYDePCCTV7+ker5vQ0fHFuxyt/CwIyAflWtx5Iwe6yKCxDYYG2YK76Sr/LsbBHGL0T+vXtaO6Drw01+rmw8ewJVqq8t3MsCx20l649yD2bs3LDJ9w7u0s8CpbJkt92pdZEN8VdYMmz4MXnLOYE4R/+5sILHV4KP7pBHGo4GAJII3iLIhTrrl9rpiWxN4yQMY6NK8cqlTqBzW+6PXnAAYnEKDWrhP6dWyloGnxgJ1V9eeJYr0W/J4B36/HiCBqtU2TgcXYw+7zT0dlsKqpx9X08D3lKcuAZZ+Ml6lB1CwHJjkCtUiPbFa38bnBT/V4OjDrSemBtnMLecL8HtC+rJa1oHiZ/ZMLq8x7oGOp4B8RlI4clDhOjq/Y4MeiJhS6sY30rdCLjQ62Y+UcnipO/x0wzW7jEozhbAcNf/xJlx3VORlaOhoiRnZZXUsc1Kn1nPpRZ1il+AEATjR3JEVcyZUG2FLJGAIP7JK5iNLnNSIehUtB3IZlKjUJqpM20Yk1RupFQSh9YymGHO9emsa6MTLtO4CnKjv6FS1ZjPiV+cEvcdAw4+ajwkyyIqj6U="
}
