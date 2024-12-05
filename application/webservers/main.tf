
#  Define the provider
provider "aws" {
  region  = "us-east-1"
  access_key = "ASIAXHSQPKZ7UYWMDBFH"
  secret_key = "4jI6/I1PYISCEvBcVNPl0kg2U5Oumtw3e2c5VgOY"
  token      = "IQoJb3JpZ2luX2VjEGEaCXVzLXdlc3QtMiJGMEQCIBpVbpgSyGK3mFJ52ckF5Pg+UkydgMXS2wO+dqf8th7vAiAnWFEoU2+f0L/BpCEzZx9mGsLJ5yZfj4IU4EFx9oqXuiquAggaEAAaDDQ5NzMxMTI0MTg1NSIM0YCMzlhRjSLsxMtBKosCIYc1HdRGbcYDePCCTV7+ker5vQ0fHFuxyt/CwIyAflWtx5Iwe6yKCxDYYG2YK76Sr/LsbBHGL0T+vXtaO6Drw01+rmw8ewJVqq8t3MsCx20l649yD2bs3LDJ9w7u0s8CpbJkt92pdZEN8VdYMmz4MXnLOYE4R/+5sILHV4KP7pBHGo4GAJII3iLIhTrrl9rpiWxN4yQMY6NK8cqlTqBzW+6PXnAAYnEKDWrhP6dWyloGnxgJ1V9eeJYr0W/J4B36/HiCBqtU2TgcXYw+7zT0dlsKqpx9X08D3lKcuAZZ+Ml6lB1CwHJjkCtUiPbFa38bnBT/V4OjDrSemBtnMLecL8HtC+rJa1oHiZ/ZMLq8x7oGOp4B8RlI4clDhOjq/Y4MeiJhS6sY30rdCLjQ62Y+UcnipO/x0wzW7jEozhbAcNf/xJlx3VORlaOhoiRnZZXUsc1Kn1nPpRZ1il+AEATjR3JEVcyZUG2FLJGAIP7JK5iNLnNSIehUtB3IZlKjUJqpM20Yk1RupFQSh9YymGHO9emsa6MTLtO4CnKjv6FS1ZjPiV+cEvcdAw4+ajwkyyIqj6U="
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {

    bucket = module.globalvars.s3_staging_backend_bucket  // Bucket from where to GET Terraform State
=======
    bucket = module.globalvars.s3_prod_backend_bucket  // Bucket from where to GET Terraform State

    key    = "network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                 // Region where bucket created
  }
}


# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "subnets" {
  for_each = toset(data.terraform_remote_state.network.outputs.public_subnet_id)

  id = each.key
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Reference subnet provisioned
resource "aws_instance" "public_vms" {
  count                       = 1
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_id[3]
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-public-webserver-4"
    }
  )
}

# Reference subnet provisioned
resource "aws_instance" "private_web_vm" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_id[0]
  vpc_security_group_ids      = [aws_security_group.private_web_sg.id]
  associate_public_ip_address = false
  user_data = templatefile("${path.module}/install_httpd.sh.tpl",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }


  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-private-webserver-5"
    }
  )
}

# Reference subnet provisioned
resource "aws_instance" "private_server_vm" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_id[1]
  vpc_security_group_ids      = [aws_security_group.private_web_sg.id]
  associate_public_ip_address = false

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-private-VM6"
    }
  )
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("sshkey.pub")
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_id[1]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "sshkey"
    destination = "sshkey"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("sshkey")
      host        = self.public_ip
    }
  }


  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion"
    }
  )
}

# Elastic IP
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}
