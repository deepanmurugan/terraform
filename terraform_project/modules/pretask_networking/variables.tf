variable "default_tags" {
  type = map(any)
  default = {
    Environment = "Stage"
    AppName     = "WebApp"
    Team        = "SQA"
    ManagedBy   = "Terraform"
  }
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "The CIDR block of the vpc"
}

variable "availability_zones" {
  type    = list(any)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnets_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  type    = list(any)
  default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "private_subnet_count" {
  type    = number
  default = 3
}

variable "public_subnet_count" {
  type    = number
  default = 2
}