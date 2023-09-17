// credits https://github.com/eborchert80/cfn-tgw-vpn/blob/main/README.md
locals {
  psk_tunnel_1 = "ZMHYCmbI5eTsWUIDNxancwTbkxm3s1c"
  psk_tunnel_2 = "jUSqxwmOSSd1ZFnm3DmpuzpRMxZHrsN4"
}

// site A
resource "aws_vpc" "site_a" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "Site A" }
}

resource "aws_internet_gateway" "site_a" {
  vpc_id = aws_vpc.site_a.id
  tags   = { Name = "IG - Site A" }
}

resource "aws_vpn_gateway" "site_a" {
  vpc_id          = aws_vpc.site_a.id
  amazon_side_asn = 65001
  tags            = { Name = "VGW Site A" }
}

resource "aws_eip" "dummy_customer" {
  tags = { Name = "Dummy customer IP" }
}


resource "aws_customer_gateway" "dummy_customer" {
  bgp_asn    = 65002
  ip_address = aws_eip.dummy_customer.public_ip
  type       = "ipsec.1"
  tags       = { Name = "Dummy customer" }
}


resource "aws_customer_gateway" "site_b_customer" {
  bgp_asn    = 65002
  ip_address = aws_vpn_connection.site_b_to_a.tunnel1_address
  type       = "ipsec.1"
  tags       = { Name = "Site B customer" }
}

resource "aws_vpn_connection" "site_a_to_b" {
  vpn_gateway_id         = aws_vpn_gateway.site_a.id
  # the below should be the site_b_customer and it needs to be set manually
  # cause it is a TF circular dependency. The commandline to run is outputted
  customer_gateway_id    = aws_customer_gateway.dummy_customer.id
  type                   = "ipsec.1"
  #  static_routes_only       = var.vpn_connection_static_routes_only
  #  local_ipv4_network_cidr  = var.vpn_connection_local_ipv4_network_cidr
  #  remote_ipv4_network_cidr = "${aws_eip.site_a_vpn_ip.public_ip}/32"
  #
  #  tunnel1_dpd_timeout_action = var.vpn_connection_tunnel1_dpd_timeout_action
  #  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions
  #  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key  = local.psk_tunnel_1
  tunnel1_startup_action = "start"
  #
  #  tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  #  tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  #  tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  #  tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  #  tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  #  tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  #
  #  tunnel2_dpd_timeout_action = var.vpn_connection_tunnel2_dpd_timeout_action
  #  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions
  #  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key  = local.psk_tunnel_2
  tunnel2_startup_action = "start"
  #
  #  tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  #  tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  #  tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  #  tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  #  tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  #  tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms

  tags = { Name = "Site A to B" }
}

// site B
resource "aws_vpc" "site_b" {
  cidr_block = "10.1.0.0/16"
  tags       = { Name = "Site B" }
}

resource "aws_internet_gateway" "site_b" {
  vpc_id = aws_vpc.site_b.id
  tags   = { Name = "IG - Site B" }
}

resource "aws_vpn_gateway" "site_b" {
  vpc_id          = aws_vpc.site_b.id
  amazon_side_asn = 65002
  tags            = { Name = "VGW Site B" }
}

resource "aws_customer_gateway" "site_a_customer" {
  bgp_asn    = 65001
  ip_address = aws_vpn_connection.site_a_to_b.tunnel1_address
  type       = "ipsec.1"
  tags       = { Name = "Site A customer" }
}

resource "aws_vpn_connection" "site_b_to_a" {
  vpn_gateway_id         = aws_vpn_gateway.site_b.id
  customer_gateway_id    = aws_customer_gateway.site_a_customer.id
  type                   = "ipsec.1"
  #  static_routes_only       = var.vpn_connection_static_routes_only
  #  local_ipv4_network_cidr  = var.vpn_connection_local_ipv4_network_cidr
  #  remote_ipv4_network_cidr = "${aws_eip.site_a_vpn_ip.public_ip}/32"
  #
  #  tunnel1_dpd_timeout_action = var.vpn_connection_tunnel1_dpd_timeout_action
  #  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions
  #  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key  = local.psk_tunnel_1
  tunnel1_startup_action = "add"
  #
  #  tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  #  tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  #  tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  #  tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  #  tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  #  tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  #
  #  tunnel2_dpd_timeout_action = var.vpn_connection_tunnel2_dpd_timeout_action
  #  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions
  #  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key  = local.psk_tunnel_2
  tunnel2_startup_action = "add"
  #
  #  tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  #  tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  #  tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  #  tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  #  tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  #  tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms

  tags = { Name = "Site B to A" }
}

output "to_run" {
  value = "aws ec2 modify-vpn-connection --vpn-connection-id ${aws_vpn_connection.site_a_to_b.id} --customer-gateway-id ${aws_customer_gateway.site_b_customer.id}"
}