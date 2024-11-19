variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC Cidr Block"
}

variable "default_tags" {
  type = map(string)
  default = {
    "Owner" = "Smriti"
    "App"   = "Web"
  }
  description = "description"
}


variable "env" {
  type        = string
  default     = "staging"
  description = "Environment of the application"
}

variable "prefix" {
  type        = string
  default     = "Assignment"
  description = "description"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "description"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  description = "description"
}

variable "nat_gateway" {
  type    = bool
  default = true
}

variable "internet_gateway" {
  type    = bool
  default = true
}