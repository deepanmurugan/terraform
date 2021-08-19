variable "default_tags" {
  type = map(any)
  default = {
    Environment = "Stage"
    AppName     = "WebApp"
    Team        = "SQA"
    ManagedBy   = "Terraform"
  }
}

variable "vpc_id" {
  default = ""
}

variable "availability_zones" {
  type    = list(any)
  default = ["us-east-2a", "us-east-2b"]
}

variable "private_subnet_id_list" {
  type    = list(any)
  default = []
}

variable "public_subnet_id_list" {
  type    = list(any)
  default = []
}

variable "public_lb_subnet_id" {
  type    = list(any)
  default = []
}