/*Resource to create VPC (Virtual Private Cloud)
|- VPC is associated to any region like london,france, us etc
|- From VPC you can create subnets and other resources
*/
resource "aws_vpc" "terraform_vpc" {
  count                = var.no_of_vpc
  cidr_block           = "10.0.${count.index}.0/24"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "vpc_${count.index}"
    Env  = "Prod"
  }
}

/* List of availability zones used to create subnets
|- in different az's for public and private subnet
*/
data "aws_availability_zones" "aws_az" {
}

/* Create single subnet in per  VPC (no_of_vpc variable defined in variables.tf )
|- using round robin method in different az
*/
resource "aws_subnet" "example" {
  count                   = var.no_of_vpc
  cidr_block              = "10.0.${count.index}.0/28"
  availability_zone       = element(data.aws_availability_zones.aws_az.names, count.index + 2)
  vpc_id                  = element(aws_vpc.terraform_vpc.*.id, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_${count.index}"
    Env  = "Prod"
  }
}

/* Fetch VPC details based on CIDR block to use below*/
data "aws_vpc" "selected" {
  cidr_block = "10.0.0.0/24"
  depends_on = ["aws_vpc.terraform_vpc"]
}

/* Create an internet gateway and attach it to only the first VPC 
|- It is going to act as bastian host to login in initially
*/
resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "igw"
    Env  = "Prod"
  }
}

/* Create route table for public subnet
|- Add a route for 10.0.0.0/8 so that all the requests goes to TGW
|- Add a route for internet gateway to send all other traffic
*/
resource "aws_route_table" "terraform_route" {
  vpc_id = data.aws_vpc.selected.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = aws_ec2_transit_gateway.aws_tgw.id
  }
  tags = {
    Name = "vpc_0_rt"
    Env  = "Prod"
  }
  depends_on = ["aws_ec2_transit_gateway.aws_tgw", "aws_ec2_transit_gateway_vpc_attachment.attach_tgw_vpc"]
}

/* Create route table for other subnets
|- Add a route for 10.0.0.0/8 so that all the requests goes to TGW
*/
resource "aws_route_table" "terraform_route_others" {
  count  = "${var.no_of_vpc}" - 1
  vpc_id = element(aws_vpc.terraform_vpc.*.id, count.index + 1)
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = aws_ec2_transit_gateway.aws_tgw.id
  }
  tags = {
    Name = "vpc_${count.index + 1}_rt"
    Env  = "Prod"
  }
  depends_on = ["aws_ec2_transit_gateway.aws_tgw", "aws_ec2_transit_gateway_vpc_attachment.attach_tgw_vpc"]
}

/* Explicitly associate the public subnet to the public route table */
resource "aws_route_table_association" "route_association_public" {
  subnet_id      = aws_subnet.example[0].id
  route_table_id = aws_route_table.terraform_route.id
}

/* Explicitly associate other subnet to the respective route table */
resource "aws_route_table_association" "route_association_others" {
  count          = "${var.no_of_vpc}" - 1
  subnet_id      = element(aws_subnet.example.*.id, count.index + 1)
  route_table_id = element(aws_route_table.terraform_route_others.*.id, count.index)
}

/* Create Transit Gateway for VPC to VPC connection */
resource "aws_ec2_transit_gateway" "aws_tgw" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "TGW"
    Env  = "Prod"
  }
}

/* Create tgw attachment for all the VPC */
resource "aws_ec2_transit_gateway_vpc_attachment" "attach_tgw_vpc" {
  count                                           = var.no_of_vpc
  subnet_ids                                      = ["${element(aws_subnet.example.*.id, count.index)}"]
  transit_gateway_id                              = aws_ec2_transit_gateway.aws_tgw.id
  vpc_id                                          = element(aws_vpc.terraform_vpc.*.id, count.index)
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  tags = {
    Name = "tgw_vpc_${count.index}_attachment"
    Env  = "Prod"
  }
}

/* Create tgw route table for the transit gateway that was created */
resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  count              = "${var.no_of_vpc}" > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.aws_tgw.id
  tags = {
    Name = "tgw_route_table"
    Env  = "Prod"
  }
}

/* Create tgw route table association
|- Associate all the tgw attachment with the route table, so that whenever traffic comes from any VPC, it will pick up this route table associated
*/
resource "aws_ec2_transit_gateway_route_table_association" "aws_rt_association" {
  count                          = var.no_of_vpc
  transit_gateway_attachment_id  = element(aws_ec2_transit_gateway_vpc_attachment.attach_tgw_vpc.*.id, count.index)
  transit_gateway_route_table_id = element(aws_ec2_transit_gateway_route_table.tgw_rt.*.id, count.index)
}

/* Create route table propagation, which will automatically add CIDR of the attachments, 
|- so that the traffic will reach the correct VPC 
*/
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_propagation" {
  count                          = var.no_of_vpc
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attach_tgw_vpc.*.id[count.index]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt[0].id
}
