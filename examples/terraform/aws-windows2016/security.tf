////////////////////////////////
// Firewalls

resource "aws_security_group" "default" {
  name        = "${var.aws_key_pair_name}-${random_id.random.hex}"
  description = "${var.aws_key_pair_name}-${random_id.random.hex}"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port         = 3389
    to_port           = 3389
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
}

  ingress {
    from_port         = 5985
    to_port           = 5986
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  # Habitat HTTP
  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9638
    to_port = 9638
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    X-Contact = "${var.aws_key_pair_name} <you@example.io>"
  }
}
