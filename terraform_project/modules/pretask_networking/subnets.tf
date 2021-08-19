resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-VPC"
    },
  )
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.private_subnet_count
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = length(var.availability_zones) > 1 ? var.availability_zones[count.index % length(var.availability_zones)] : var.availability_zones[0]
  map_public_ip_on_launch = false
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-${element(var.availability_zones, count.index)}-private-subnet"
    },
  )
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.public_subnet_count
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = length(var.availability_zones) > 1 ? var.availability_zones[count.index % length(var.availability_zones)] : var.availability_zones[0]
  map_public_ip_on_launch = false
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-${element(var.availability_zones, count.index)}-public-subnet"
    },
  )
}