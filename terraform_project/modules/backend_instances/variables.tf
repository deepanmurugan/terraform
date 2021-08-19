variable "default_tags" {
  type = map(any)
  default = {
    Environment = "Stage"
    AppName     = "WebApp"
    Team        = "SQA"
    ManagedBy   = "Terraform"
  }
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
  type    = bool
  default = false
}

variable "tenancy" {

}

variable "volume_size" {

}

variable "volume_type" {

}

variable "private_subnet_id" {
  type    = list(any)
  default = []
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz35nZLTTSugCndPCuTDR+nXWto+O+BRgOKEECAipFBgzT33Vh9jlgQORC7gD7q5Jd3nYHRt+63x6MQLfE3mXuy6BUNWQEYmgHxICFouDcnX3YO0VTKkG4MiGF0fSpQ5tfLlLV3koebnKlNJe1loZxMJNGDVWzaN/0ENjGDivAjU1qz1JuAcM9YP+9l6APoTZgigEzSyruEGAlbo1bX1TX5Ij6s5mXB3VJoNCKeU3UHAvndVo2ECdn3pVkd70ZCSoAARyJI4uYj/Ls322jGzoOTCyBgJdVgsB31qK6m3MMuPKjN+bUhSVEn669dZgNwiw0A7Rm8hEWhTjNkVXx3zjXN1vEMfKslL9/nRWNkV31QEbXDKvPh6ZxGMJrYu8sYKyTh++pHeAOc6pmObqywtTKsqjI8YdGRpz4nVYfP2CY51Omu5UPzx6bUKEXp7RHLuwrwSYt2oL94hBI0oZEFN6uPuNqBvB9sEp4P+3An1CpjClLss1duMwC6i/3J6WeeW0= deepabi@DeepAbis-MacBook-Air.local"
}

variable "vpc_id" {

}

variable "vpc_security_group_ids" {
  type    = list(any)
  default = []
}

variable "description" {
  default = "Web security group"
}

variable "lb_security_group" {
  default = ""
}

variable "to_port" {
  default = "443"
}