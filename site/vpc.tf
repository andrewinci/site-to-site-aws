resource "aws_vpc" "site_a" {
  cidr_block = var.cidr_block
  tags       = { Name = "Site ${var.name}" }
}

resource "aws_internet_gateway" "site_a" {
  vpc_id = aws_vpc.site_a.id
  tags   = { Name = "IG - Site ${var.name}" }
}

resource "aws_subnet" "site_a" {
  vpc_id     = aws_vpc.site_a.id
  cidr_block = var.cidr_block

  tags = { Name = "Site ${var.name}" }
}

# Allow resources in the VPC to access internet
resource "aws_route" "igw_route" {
  route_table_id         = aws_vpc.site_a.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.site_a.id
}