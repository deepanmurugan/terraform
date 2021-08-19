# Common variables
# ----------------
region = "us-east-2"
default_tags = {
  Environment = "stage"
  AppName     = "WebApp"
  Team        = "SQA"
  ManagedBy   = "Terraform"
}

# Networking module variables
# ---------------------------
vpc_cidr             = "10.0.0.0/16"
public_subnet_count  = 5
private_subnet_count = 4
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
availability_zones   = ["us-east-2a", "us-east-2b", "us-east-2c"]

# LoadBalancer module variables
# -----------------------------
app_name                         = "testapp"
internal                         = false
lb_type                          = "application"
enable_cross_zone_load_balancing = true
delete_protection                = false
from_port                        = 80
from_protocol                    = "HTTP"
to_port                          = 80
to_protocol                      = "HTTP"
description                      = "test sg"
enable_http_to_https_redirect    = "false"

# Backend EC2 instance variables
# ------------------------------
instance_type           = "t2.micro"
disable_api_termination = false
tenancy                 = "default"
volume_size             = "8"
volume_type             = "gp2"
public_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCz35nZLTTSugCndPCuTDR+nXWto+O+BRgOKEECAipFBgzT33Vh9jlgQORC7gD7q5Jd3nYHRt+63x6MQLfE3mXuy6BUNWQEYmgHxICFouDcnX3YO0VTKkG4MiGF0fSpQ5tfLlLV3koebnKlNJe1loZxMJNGDVWzaN/0ENjGDivAjU1qz1JuAcM9YP+9l6APoTZgigEzSyruEGAlbo1bX1TX5Ij6s5mXB3VJoNCKeU3UHAvndVo2ECdn3pVkd70ZCSoAARyJI4uYj/Ls322jGzoOTCyBgJdVgsB31qK6m3MMuPKjN+bUhSVEn669dZgNwiw0A7Rm8hEWhTjNkVXx3zjXN1vEMfKslL9/nRWNkV31QEbXDKvPh6ZxGMJrYu8sYKyTh++pHeAOc6pmObqywtTKsqjI8YdGRpz4nVYfP2CY51Omu5UPzx6bUKEXp7RHLuwrwSYt2oL94hBI0oZEFN6uPuNqBvB9sEp4P+3An1CpjClLss1duMwC6i/3J6WeeW0= deepabi@DeepAbis-MacBook-Air.local"
custom_ami              = false
custom_ami_id           = "test"