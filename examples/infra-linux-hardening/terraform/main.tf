provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "random_id" "random" {
  byte_length = 4
}

resource "aws_vpc" "default" {
  cidr_block = "10.1.0.0/16"

  tags = {
    name = "${var.aws_key_pair_name}_${random_id.random.hex}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
}
