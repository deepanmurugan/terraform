variable "ecs_cluster" {
  default     = "webapp"
  description = "Desired number of instances in the cluster"
}

data "aws_availability_zones" "aws_az" {
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "no_of_public_subnet" {
  default = "2"
}

variable "no_of_private_subnet" {
  default = "2"
}

variable "in_subnets_max" {
  default = "4"
}

variable "instance_type" {
  default = "t2.xlarge"
}

variable "key_name" {
  default = "yahookey"
}

variable "asg_max_size" {
  default = "6"
}

variable "asg_min_size" {
  default = "2"
}

variable "asg_desired_size" {
  default = "2"
}

variable "ecs_desired_count" {
  default = "9"
}

# Get the latest ECS AMI
data "aws_ami" "latest_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["591542846629"] # AWS
}
