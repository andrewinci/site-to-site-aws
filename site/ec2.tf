resource "aws_security_group" "allow_ssh" {
  name   = "Test ec2 ${var.name} sg"
  vpc_id = aws_vpc.site_a.id

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
  subnet_id                   = aws_subnet.site_a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  key_name                    = "site2site-test"

  tags = {
    Name = "Test machine ${var.name}"
  }
}
