output "public_lb_subnet_id" {
  value = [for subnet_ids in local.public_availability_zone_subnets : subnet_ids[0]]
}