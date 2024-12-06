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

# provider "aws" {
#   region  = "us-east-1"
#   access_key = "ASIAXHSQPKZ7SKUV2N4J"
#   secret_key = "OqgWEtoGhZ9G3rxL47mhxIh3LJXjz6tMlzN26Hdk"
#   token      = "IQoJb3JpZ2luX2VjEGMaCXVzLXdlc3QtMiJHMEUCIQCM7AyKnxusPPtfrQF6YMNl1fP4kyySY9DBVYE4cwkGrgIgUeie32Wh/LyDO8Pjot7XRUssmb6cEx6VX0hxUG+vHncqrgIIHBAAGgw0OTczMTEyNDE4NTUiDGho+CexmLyECWIG5SqLAhYcNSa5aeEGxhOlVOFYHZI8/pLpgIysIVxeMdKIHNoFssyUo3ok2jlc+hMteZUmFR1uLqQW7ehCYfAhMUVWTSqDPaByP99WW2K1oNbbh6lHVG+vlnN7DnLpxAmHLoizcL/GlQFDGrEnk1XsItLkRf+61OBnWhV95tThhHtdZyhJVJ+J7kjEr9u8lyRs/9FLSnwh6+B0Yp7u1V/MjkcYgQaYaOhRKWbIy9tcNDRLXf6+n/WTYx6yTOXj9au5vauNczaWm8x2NV9w08kAgI1UikprawQmuAmJ/SOD4eVL1x5jaUupBo1ShJT4I7LdK569w4mw6jDYWjwIuP36u7+I4KIQjjK1Nu8bSoDb/TCJ+Me6BjqdAeHQ6A4KMqJJEQb/KCsxkGsMYX54gUFntYXhJjNAStp2l4ijbJLdMqsrAmZZ4pfjBA+fD/cwv00VLR2i73FQ7Zdab3PBHDcdi4TraBGAQynAUxUpt3Ky5v6N7uXRxoWs35b0lnWMvfbi6VTePwuqCTD0ayhvIm7PKzPMO5NM5WAaL92BG6LVW1OdRpoCB3rCC5Np5/l6sR54tVJuR/g="
# }
