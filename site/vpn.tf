resource "aws_vpn_gateway" "site_a" {
  vpc_id          = aws_vpc.site_a.id
  amazon_side_asn = var.bgp_asn
  tags            = { Name = "VGW Site ${var.name}" }
}

resource "aws_customer_gateway" "site_b_customer" {
  bgp_asn    = var.customer_bgp_asn
  ip_address = var.customer_gateway_address
  type       = "ipsec.1"
  tags       = { Name = "Site ${var.target_site_name} customer" }
}

resource "aws_vpn_connection_route" "route" {
  destination_cidr_block = var.local_ipv4_network_cidr
  vpn_connection_id      = aws_vpn_connection.site_a_to_b.id
}

resource "aws_vpn_gateway_route_propagation" "route_propagation" {
  vpn_gateway_id = aws_vpn_gateway.site_a.id
  route_table_id = aws_vpc.site_a.default_route_table_id
}

resource "aws_vpn_connection" "site_a_to_b" {
  vpn_gateway_id           = aws_vpn_gateway.site_a.id
  # the below should be the site_b_customer and it needs to be set manually
  # cause it is a TF circular dependency. The commandline to run is outputted
  customer_gateway_id      = aws_customer_gateway.site_b_customer.id
  type                     = "ipsec.1"
  static_routes_only       = true
  # Customer cidr
  local_ipv4_network_cidr  = var.local_ipv4_network_cidr
  # AWS CIDR
  remote_ipv4_network_cidr = aws_vpc.site_a.cidr_block

  # Tunnel 1
  tunnel1_preshared_key  = var.psk_tunnel_1
  tunnel1_startup_action = var.tunnel_startup_action
  #  tunnel1_dpd_timeout_action = var.vpn_connection_tunnel1_dpd_timeout_action
  #  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions
  #  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  #  tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  #  tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  #  tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  #  tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  #  tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  #  tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms

  # Tunnel 2
  tunnel2_preshared_key  = var.psk_tunnel_2
  tunnel2_startup_action = var.tunnel_startup_action
  #  tunnel2_dpd_timeout_action = var.vpn_connection_tunnel2_dpd_timeout_action
  #  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions
  #  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  #  tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  #  tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  #  tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  #  tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  #  tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  #  tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms

  tags = { Name = "VPN ${var.name} to ${var.target_site_name}" }
}
