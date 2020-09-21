output "vpc_id" {
  value = aws_vpc.mw_vpc.id
}

output "public_subnets" {
  value = aws_subnet.mw_public_subnet.*.id
}

output "public_cidrs" {
  value = aws_subnet.mw_public_subnet.*.cidr_block
}

output "application_subnets" {
  value = aws_subnet.mw_app_subnet.*.id
}

output "application_cidrs" {
  value = aws_subnet.mw_app_subnet.*.cidr_block
}
output "database_subnets" {
  value = aws_subnet.mw_db_subnet.*.id
}

output "database_cidrs" {
  value = aws_subnet.mw_db_subnet.*.cidr_block
}

output "elb_dns_name" {
  value = "${aws_elb.mw_elb.dns_name}"
 }
