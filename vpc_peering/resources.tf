/* Block to obtain VPC requester data using VPC ID Varible */
data "aws_vpc" "vpc_requester" {
  id = "${var.requester_vpc_id}"
}

/* Block to obtain VPC accepter data using VPC ID Varible */
data "aws_vpc" "vpc_accepter" {
  id = "${var.accepter_vpc_id}"
}

/* Block to obtain requester route table data using VPC CIDR */
data "aws_route_table" "requester_rt" {
  vpc_id = "${var.requester_vpc_id}"
}

/* Block to obtain accepter route table data using VPC CIDR */
data "aws_route_table" "accepter_rt" {
  vpc_id = "${var.accepter_vpc_id}"
}

/* Creates a CPC Peering Connection between requester and accepter */
resource "aws_vpc_peering_connection" "requester_accepter_peering" {
  peer_owner_id = "${var.requester_account_id}"
  peer_vpc_id   = "${var.accepter_vpc_id}"
  vpc_id        = "${var.requester_vpc_id}"
  auto_accept   = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "VPC_Peering"
    Env  = "Prod"
  }
}

/* Add VPC Peering route entry to the route tables of requester subnet */
resource "aws_route" "requester_route" {
  count                     = "${length(data.aws_route_table.requester_rt.*.id)}"
  route_table_id            = "${data.aws_route_table.requester_rt.*.id[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.vpc_accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester_accepter_peering.id}"
}


/* Add VPC Peering route entry to the route tables of requester subnet */
resource "aws_route" "accepter_route" {
  count                     = "${length(data.aws_route_table.accepter_rt.*.id)}"
  route_table_id            = "${data.aws_route_table.accepter_rt.*.id[count.index]}"
  destination_cidr_block    = "${data.aws_vpc.vpc_requester.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester_accepter_peering.id}"
}
