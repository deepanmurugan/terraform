# Define a vpc
resource "aws_vpc" "ECS-VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ECS-VPC"
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "ECS-IG" {
  vpc_id = aws_vpc.ECS-VPC.id
  tags = {
    Name = "ECS-IG"
  }
}

# Create EIP for NAT Gateway
resource "aws_eip" "ecs-nat-eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.ECS-IG"]
  tags = {
    Name = "ECS-NAT-EIP"
    Env  = "Prod"
  }
}

# Create 2 public subnet where we launch our public facing ALB
resource "aws_subnet" "public_subnet" {
  count                   = var.no_of_public_subnet
  cidr_block              = cidrsubnet(var.vpc_cidr, var.in_subnets_max, count.index)
  availability_zone       = element(data.aws_availability_zones.aws_az.names, count.index)
  vpc_id                  = aws_vpc.ECS-VPC.id
  map_public_ip_on_launch = true
  tags = {
    Name = "ECS-Public-Subnet-${count.index}"
    Env  = "Prod"
  }
}

# Create 2 private subnet for ECS Instances
resource "aws_subnet" "private_subnet" {
  count                   = var.no_of_private_subnet
  cidr_block              = cidrsubnet(var.vpc_cidr, var.in_subnets_max, var.no_of_public_subnet + count.index)
  availability_zone       = element(data.aws_availability_zones.aws_az.names, count.index)
  vpc_id                  = aws_vpc.ECS-VPC.id
  map_public_ip_on_launch = true
  tags = {
    Name = "ECS-Private-Subnet-${count.index}"
    Env  = "Prod"
  }
}

# Create NAT Gateway for private subnets
resource "aws_nat_gateway" "ecs-nat" {
  allocation_id = aws_eip.ecs-nat-eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    Name = "ECS-NAT"
    Env  = "Prod"
  }
}

# Create route table for public subnets and add default route for Internet Gateway
resource "aws_route_table" "ECS-Public-rt" {
  vpc_id = aws_vpc.ECS-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ECS-IG.id
  }
  tags = {
    Name = "ECS-Public-rt"
  }
}

# Create route table for private subnets and add default route for NAT Gateway
resource "aws_route_table" "ECS-Private-rt" {
  vpc_id = aws_vpc.ECS-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = "${aws_nat_gateway.ecs-nat.id}"
    gateway_id = aws_internet_gateway.ECS-IG.id
  }
  tags = {
    Name = "ECS-Private-rt"
  }
}

# Associate the public routing table to both public subnets
resource "aws_route_table_association" "ecs-public-rt-association" {
  count          = var.no_of_public_subnet
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.ECS-Public-rt.id
}

# Associate the private routing table to both private subnets
resource "aws_route_table_association" "ecs-private-rt-association" {
  count          = var.no_of_private_subnet
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.ECS-Private-rt.id
}
