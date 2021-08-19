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

variable "public_subnet_id" {
  type    = list(any)
  default = []
}

variable "internal" {
}

variable "lb_type" {

}

variable "security_groups" {
  type    = list(any)
  default = []
}

variable "enable_cross_zone_load_balancing" {
  type = bool
}

variable "delete_protection" {
  type = bool
}

variable "enable_http_to_https_redirect" {
  type = bool
}

variable "from_port" {

}

variable "to_port" {

}

variable "from_protocol" {

}

variable "to_protocol" {

}

variable "description" {
  default = "Allow Internet traffic"
}
variable "target_instance_id" {
  type    = list(any)
  default = []
}