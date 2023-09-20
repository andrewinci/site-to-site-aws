resource "aws_vpc" "team" {
  cidr_block = "10.145.0.0/16"
  tags       = { Name = "Test team" }
}

resource "aws_internet_gateway" "team" {
  vpc_id = aws_vpc.team.id
  tags   = { Name = "IG - Test team" }
}

resource "aws_subnet" "team" {
  vpc_id     = aws_vpc.team.id
  cidr_block = aws_vpc.team.cidr_block

  tags = { Name = "Test team subnet" }
}

# Allow resources in the VPC to access internet
resource "aws_route" "igw_route" {
  route_table_id         = aws_vpc.team.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.team.id
}

resource "aws_security_group" "allow_ssh" {
  name   = "Test ec2 team sg"
  vpc_id = aws_vpc.team.id

  ingress {
    description = "SSH from internet"
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Internet access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "test_machine" {
  ami                         = "ami-0648880541a3156f7"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.team.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  key_name                    = "site2site-test"

  tags = {
    Name = "Test machine for the test team"
  }
}
