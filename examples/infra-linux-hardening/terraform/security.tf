resource "aws_security_group" "default" {
  name        = "${var.aws_key_pair_name}-${random_id.random.hex}"
  description = "${var.aws_key_pair_name}-${random_id.random.hex}"
  vpc_id      = aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Habitat Supervisor HTTP
  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Access to internet for both TCP and UDP
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    X-Contact = var.aws_key_pair_name
  }
}
