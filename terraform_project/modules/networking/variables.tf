variable "default_tags" {
  type = map
  default = {
    Environment = "Stage"
    AppName = "WebApp"
    Team = "SQA"
    ManagedBy = "Terraform"
  }
}

variable "vpc_id" {
  default = ""
}

variable "availability_zones" {
 type = list
 default = ["us-east-2a", "us-east-2b"]
}

variable "private_subnet_id_list" {
  type = list
  default = []
}

variable "public_subnet_id_list" {
  type = list
  default = []
}

variable "public_lb_subnet_id" {
  type = list
  default = []
}