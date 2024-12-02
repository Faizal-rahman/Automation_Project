variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC Cidr Block"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment of the application"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24","10.1.3.0/24","10.1.4.0/24"]
  description = "description"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  description = "description"
}