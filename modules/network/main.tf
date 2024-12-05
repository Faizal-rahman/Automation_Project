locals {
  name_prefix = "${var.prefix}-${var.env}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

#configration for public subnet
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index + 1]

  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-public-subnet-${count.index}"
    }
  )
}

resource "aws_internet_gateway" "vpc_igw" {
  count  = var.internet_gateway == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-igw"
    }
  )

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-public-route-table"
    }
  )
}

resource "aws_route" "public_route" {
  count                  = var.internet_gateway ? 1 : 0
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_igw[0].id
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

#Private subnet configuraiton

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index + 1]

  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-private-subnet-${count.index}"
    }
  )
}

resource "aws_eip" "vpc_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.vpc_igw]
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-eip"
    }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.nat_gateway == true ? 1 : 0
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.vpc_eip.id
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-nat-gateway"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-private-route-table"
    }
  )
}

resource "aws_route" "private_route" {
  count                  = var.nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[0].id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

provider "aws" {
  region  = "us-east-1"
  access_key = "ASIAXHSQPKZ7UYWMDBFH"
  secret_key = "4jI6/I1PYISCEvBcVNPl0kg2U5Oumtw3e2c5VgOY"
  token      = "IQoJb3JpZ2luX2VjEGEaCXVzLXdlc3QtMiJGMEQCIBpVbpgSyGK3mFJ52ckF5Pg+UkydgMXS2wO+dqf8th7vAiAnWFEoU2+f0L/BpCEzZx9mGsLJ5yZfj4IU4EFx9oqXuiquAggaEAAaDDQ5NzMxMTI0MTg1NSIM0YCMzlhRjSLsxMtBKosCIYc1HdRGbcYDePCCTV7+ker5vQ0fHFuxyt/CwIyAflWtx5Iwe6yKCxDYYG2YK76Sr/LsbBHGL0T+vXtaO6Drw01+rmw8ewJVqq8t3MsCx20l649yD2bs3LDJ9w7u0s8CpbJkt92pdZEN8VdYMmz4MXnLOYE4R/+5sILHV4KP7pBHGo4GAJII3iLIhTrrl9rpiWxN4yQMY6NK8cqlTqBzW+6PXnAAYnEKDWrhP6dWyloGnxgJ1V9eeJYr0W/J4B36/HiCBqtU2TgcXYw+7zT0dlsKqpx9X08D3lKcuAZZ+Ml6lB1CwHJjkCtUiPbFa38bnBT/V4OjDrSemBtnMLecL8HtC+rJa1oHiZ/ZMLq8x7oGOp4B8RlI4clDhOjq/Y4MeiJhS6sY30rdCLjQ62Y+UcnipO/x0wzW7jEozhbAcNf/xJlx3VORlaOhoiRnZZXUsc1Kn1nPpRZ1il+AEATjR3JEVcyZUG2FLJGAIP7JK5iNLnNSIehUtB3IZlKjUJqpM20Yk1RupFQSh9YymGHO9emsa6MTLtO4CnKjv6FS1ZjPiV+cEvcdAw4+ajwkyyIqj6U="
}
