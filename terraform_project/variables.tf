variable "default_tags" {
  type = map
    default = {
      Environment = "Stage"
      AppName = "WebApp"
      Team = "SQA"
      ManagedBy = "Terraform"
    }
}

variable "env" {
  default = ""
}
variable "region" {
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "vpcid" {
  default = ""
}

variable "public_subnet" {
  type = bool
  default = false
}

variable "availability_zones" {
 type = list 
}

variable "app_name" {
}

variable "internal" { 
}

variable "lb_type" {

}

variable "security_groups" {
  type = list
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
  default = "443"
}

variable "from_protocol" {
  
}

variable "to_protocol" {
  
}

variable "description" {
  
}

variable "custom_ami" {
  type = bool
}

variable "custom_ami_id" {
  default = "custom_ami_id"
}

variable "instance_type" {

}

variable "disable_api_termination" {
  
}

variable "tenancy" {

}

variable "volume_size" {

}

variable "volume_type" {

}

variable "private_subnet_id" {
  type = list
  default = []
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz35nZLTTSugCndPCuTDR+nXWto+O+BRgOKEECAipFBgzT33Vh9jlgQORC7gD7q5Jd3nYHRt+63x6MQLfE3mXuy6BUNWQEYmgHxICFouDcnX3YO0VTKkG4MiGF0fSpQ5tfLlLV3koebnKlNJe1loZxMJNGDVWzaN/0ENjGDivAjU1qz1JuAcM9YP+9l6APoTZgigEzSyruEGAlbo1bX1TX5Ij6s5mXB3VJoNCKeU3UHAvndVo2ECdn3pVkd70ZCSoAARyJI4uYj/Ls322jGzoOTCyBgJdVgsB31qK6m3MMuPKjN+bUhSVEn669dZgNwiw0A7Rm8hEWhTjNkVXx3zjXN1vEMfKslL9/nRWNkV31QEbXDKvPh6ZxGMJrYu8sYKyTh++pHeAOc6pmObqywtTKsqjI8YdGRpz4nVYfP2CY51Omu5UPzx6bUKEXp7RHLuwrwSYt2oL94hBI0oZEFN6uPuNqBvB9sEp4P+3An1CpjClLss1duMwC6i/3J6WeeW0= deepabi@DeepAbis-MacBook-Air.local"
}

variable "lb_security_group" {
  default = ""
}

variable "target_instance_id" {
  type = list
  default = []
}

variable "private_subnet_count" {
  type = number
  default = 6
}

variable "public_subnet_count" {
  type = number
  default = 6
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