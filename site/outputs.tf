output "vpn_id" {
  value = aws_vpn_connection.site_a_to_b.id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.site_b_customer.id
}

output "tunnel1_address" {
  value = aws_vpn_connection.site_a_to_b.tunnel1_address
}