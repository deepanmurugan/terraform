data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_id_list)
  id = each.key
}

data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_id_list)
  id = each.key
}

locals {
  public_availability_zone_subnets = {
    for s in data.aws_subnet.public : s.availability_zone => s.id...
  }
}

locals {
  private_availability_zone_subnets = {
    for s in data.aws_subnet.private : s.availability_zone => s.id...
  }
}

resource "aws_internet_gateway" "ig" {
  count = 1
  vpc_id = var.vpc_id
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-igw"
    },
  )
}

resource "aws_eip" "nat_eip" {
  for_each = toset(var.availability_zones)
  vpc = true
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-EIP-${each.key}"
    },
  )
}

resource "aws_nat_gateway" "nat" {
  for_each = toset(var.availability_zones)
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = local.public_availability_zone_subnets[each.key][0]
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-NAT-${each.key}"
    },
  )
}

resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id = var.vpc_id
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-private-route-table-${each.key}"
    },
  )
}

resource "aws_route_table" "public" {
  for_each = toset(var.availability_zones)
  vpc_id = var.vpc_id
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-public-route-table-${each.key}"
    },
  )
}

 resource "aws_route" "public_internet_gateway" {
  for_each = toset(var.availability_zones)
  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig[0].id
}

resource "aws_route" "private_nat_gateway" {
  for_each = toset(var.availability_zones)
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

locals {
  public_subnet_to_az = flatten([
   for az,subnets in local.public_availability_zone_subnets : [
    for subnet in subnets : {
      public_azs = az
      public_subnetid = subnet
    }
   ]
 ])
}

locals {
  private_subnet_to_az = flatten([
   for az,subnets in local.private_availability_zone_subnets : [
    for subnet in subnets : {
      private_azs = az
      private_subnetid = subnet
    }
   ]
 ])
}

resource "aws_route_table_association" "public" {
  for_each = {
    for subnets in local.public_subnet_to_az :
      "${subnets.public_azs}.${subnets.public_subnetid}" => subnets
  }
  subnet_id = each.value.public_subnetid
  route_table_id = aws_route_table.public[each.value.public_azs].id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for subnets in local.private_subnet_to_az :
      "${subnets.private_azs}.${subnets.private_subnetid}" => subnets
  }
  subnet_id = each.value.private_subnetid
  route_table_id = aws_route_table.private[each.value.private_azs].id
}