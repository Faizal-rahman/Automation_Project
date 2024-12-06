
#  Define the provider
 provider "aws" {
    region  = "us-east-1"
    access_key = "ASIA3TRMDFYD6T2B4FWL"
    secret_key = "BNiArGtIYJOcfebwsE5eO5GLB1WBkCZquR+R67K5"
    token      = "IQoJb3JpZ2luX2VjEHUaCXVzLXdlc3QtMiJHMEUCIQD2bLaAVM+RmJHJv9oZKx9mAgSGwmKBixWAvKbgjfZHBQIgO/Z3KunXZbyDZAMDk6R44n9C6OQ77erEDoVhdouMUSsqrgIILhACGgw3OTc4ODI2NTgzMTEiDG0fNUxGyATHxJ4pDiqLAmdK2Wjyi2UocMYzvNLpu7P6qtz0Ms5VMiD+X5njEpg0RW4Tj1rrE9/jB4LtfWbRkEfOe8igyl1oBpk610a79OY3b1sqAI+vQLxYRgFbcAfVpuJRpjBSgkMV6fw6gkNq43F9hirEVleqUSgzQAqRFahiY9Y4CGQQQn2X9WVyoqGnei67QFQdDfRmpKcNHx5mCrpXdqSP5ZHY6mlqG5rIi2y6kmWR4ZUIlJ/sOkrhjGyi+UBm3dMviuBI27j+J5BhxpT/fMWpjTNBL1iDhKYKJoZzUBpskus2oJ5HB7/4PPEzM+Qkje4/U8Rg5r3i3NkkZ+BbL44+GTwj3Ni0QymZ5ttt4OuMFYidvm8SJDDt2su6BjqdAQJJv38kQFp1J7U8QUa5Posy4EwBN+eBKHnQvjLi3KvCaS7IBbPeXEO3NwCxx9zDtw5+jBnm9iu0NNOzBcJcsIFwsgHdUq6wMPeYvsYlX+xntnPta+xP40/+xytVmsfgZ17ZBBzoJ5Pd9wqmQ5yOEHjLltfD9a+3M065unYgz5LMi5Hlte1R4fFzjGSmqMfNSnrxSNDvRaLu48wjTVo="
  }
 - name: Configure SSH Key for Webserver
        run: |
          mkdir -p ~/.ssh
          echo "SHA256:yXalKXEuVtXiRagXFxgYA1rvdtTn51KadZ319IpJL54 my-key" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H github.com >> ~/.ssh/known_hosts

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
