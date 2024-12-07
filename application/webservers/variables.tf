# Instance type
variable "instance_type" {
  default = {

    "test"    = "t3.micro"
    "staging" = "t2.micro"
    "dev"     = "t2.micro"
    "nonprod" = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}