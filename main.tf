#credits
#  - https://github.com/eborchert80/cfn-tgw-vpn/blob/main/README.md
#  - https://github.com/cloudposse/terraform-aws-vpn-connection
locals {
  psk_tunnel_1 = "ZMHYCmbI5eTsWUIDNxancwTbkxm3s1c"
  psk_tunnel_2 = "jUSqxwmOSSd1ZFnm3DmpuzpRMxZHrsN4"
}

resource "aws_eip" "dummy_customer" {
  tags = { Name = "Dummy customer IP" }
}

# Site a VPN created with a dummy customer gateway
# that will need to be replaced with the output command line
module "site_a" {
  source                   = "./site"
  name                     = "A"
  target_site_name         = "B"
  cidr_block               = "10.0.0.0/24"
  local_ipv4_network_cidr  = "10.1.0.0/24"
  psk_tunnel_1             = local.psk_tunnel_1
  psk_tunnel_2             = local.psk_tunnel_2
  customer_gateway_address = aws_eip.dummy_customer.public_ip
  tunnel_startup_action    = "start"
  bgp_asn                  = 65001
  customer_bgp_asn         = 65002
}

module "site_b" {
  source                   = "./site"
  name                     = "B"
  target_site_name         = "A"
  cidr_block               = "10.1.0.0/24"
  local_ipv4_network_cidr  = "10.0.0.0/24"
  psk_tunnel_1             = local.psk_tunnel_1
  psk_tunnel_2             = local.psk_tunnel_2
  customer_gateway_address = module.site_a.tunnel1_address
  tunnel_startup_action    = "add"
  bgp_asn                  = 65002
  customer_bgp_asn         = 65001
  depends_on               = [module.site_a]
}


resource "aws_customer_gateway" "site_b_customer" {
  bgp_asn    = 65002
  ip_address = module.site_b.tunnel1_address
  type       = "ipsec.1"
  tags       = { Name = "Site B customer" }
}

output "swap_the_customer" {
  value = "aws ec2 modify-vpn-connection --vpn-connection-id ${module.site_a.vpn_id} --customer-gateway-id ${aws_customer_gateway.site_b_customer.id}"
}