
#  Define the provider
 provider "aws" {
    region  = "us-east-1"
    access_key = "ASIAXHSQPKZ7XLECNLND"
    secret_key = "fUerXDTTx2iNSO5vnEDI0bNWnfzyLMHqghT1x/HZ"
    token      = "IQoJb3JpZ2luX2VjEHQaCXVzLXdlc3QtMiJHMEUCIQDDK0LSKtcynncDPwM2Yjc8wfQW10ligfhyva/0Jl2buQIgOvubn4Xw0ZkI58X48Nym7NAkRPvNwtyJb/S2QlMrYbUqrgIILRAAGgw0OTczMTEyNDE4NTUiDJtEB5RHpDTbtbKZ6iqLAosd9ppIBlB8xZifIJD0olwfZsgxQa1ILknFwPYowrqAVJHXbKfY6IGWxkzBqBT7yfYYBU0KGFZulF7GOo/zTGaH2MYNWs1p+/iiBPZrN2s8yPDD/u2cksz57wTUXyUpwyd5caeuzEfHN+JeGI9u3+4ZX+00GjVUK13hn50InqtT0TaIrQzgDiffKji+gTwHXqjC/YHkuzFvLDycZadVugW5L9+z/C4ZJfasAV9UQwxi8rg51UPBZA6j44KrdeiPOTqI4jmAbvsxn5+tdtdGUkuecwBZLGBTuz+GEmM1u/ogNwf54hM7LjtclC5waHS16mr0yuHlzwSj355ZtHZvU42/qrwaKSbNdsYX8DCS0cu6BjqdAd1fMsLZ/jc0gt4DX5kE8zWYpx37y25+Z8gzC6SflH5m4hOzoigwhzvtyrGuCJfXlvy7fDojMvliJiP8erlA7O6+lE6og0ifuWZFO57nJWya+fEBC7JEDRiRPmK3RdyCSfprVEr2np52IDAdBNis99Kk1GyeXWluV1D+rZlcZOLyuSWuhwvg+iD4cgFfwhznrAzPrTgIVH1CpE4daUQ="
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
