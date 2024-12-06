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
    access_key = "ASIA3TRMDFYD6T2B4FWL"
    secret_key = "BNiArGtIYJOcfebwsE5eO5GLB1WBkCZquR+R67K5"
    token      = "IQoJb3JpZ2luX2VjEHUaCXVzLXdlc3QtMiJHMEUCIQD2bLaAVM+RmJHJv9oZKx9mAgSGwmKBixWAvKbgjfZHBQIgO/Z3KunXZbyDZAMDk6R44n9C6OQ77erEDoVhdouMUSsqrgIILhACGgw3OTc4ODI2NTgzMTEiDG0fNUxGyATHxJ4pDiqLAmdK2Wjyi2UocMYzvNLpu7P6qtz0Ms5VMiD+X5njEpg0RW4Tj1rrE9/jB4LtfWbRkEfOe8igyl1oBpk610a79OY3b1sqAI+vQLxYRgFbcAfVpuJRpjBSgkMV6fw6gkNq43F9hirEVleqUSgzQAqRFahiY9Y4CGQQQn2X9WVyoqGnei67QFQdDfRmpKcNHx5mCrpXdqSP5ZHY6mlqG5rIi2y6kmWR4ZUIlJ/sOkrhjGyi+UBm3dMviuBI27j+J5BhxpT/fMWpjTNBL1iDhKYKJoZzUBpskus2oJ5HB7/4PPEzM+Qkje4/U8Rg5r3i3NkkZ+BbL44+GTwj3Ni0QymZ5ttt4OuMFYidvm8SJDDt2su6BjqdAQJJv38kQFp1J7U8QUa5Posy4EwBN+eBKHnQvjLi3KvCaS7IBbPeXEO3NwCxx9zDtw5+jBnm9iu0NNOzBcJcsIFwsgHdUq6wMPeYvsYlX+xntnPta+xP40/+xytVmsfgZ17ZBBzoJ5Pd9wqmQ5yOEHjLltfD9a+3M065unYgz5LMi5Hlte1R4fFzjGSmqMfNSnrxSNDvRaLu48wjTVo="
  }
