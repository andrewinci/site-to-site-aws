variable "name" {
  description = "Site name"
}

variable "target_site_name" {
  description = "Target site name"
}

variable "cidr_block" {

}

variable "psk_tunnel_1" {
  type = string
}

variable "psk_tunnel_2" {
  type = string
}

variable "local_ipv4_network_cidr" {
  description = "Second site cidr block"
}

variable "customer_gateway_address" {
  description = "Tunnel IP address. If not set, a dummy customer gateway will be created."
  default = null
}

variable "tunnel_startup_action" {

}

variable "bgp_asn" {

}
variable "customer_bgp_asn" {

}