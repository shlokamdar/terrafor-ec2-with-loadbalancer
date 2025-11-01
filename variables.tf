# variables.tf
#VPC CIDR Block Variable
variable "cidr_block" {
  description = "The CIDR block for the VPC"  
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.3.0/24"
}


