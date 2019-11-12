variable "vpc_cidr_block" { default = "10.1.0.0/16" }
variable "subnet_cidr_block" { default = "10.1.2.0/24" }
variable "ami_value" { default = "ami-00dc79254d0461090" }
variable "instance_type" { default = "t2.micro" }
variable "subnet_cidr_block_2" { default = "10.1.3.0/24" }
variable "no_of_public_subnet" { default = 2 }
variable "no_of_private_subnet" { default = 2 }
variable "in_subnets_max" { default = 4 }
