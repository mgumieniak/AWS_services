resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.network_name}_private_route_table"
  }
}

resource "aws_route_table_association" "priv_subnet_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_a_priv.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "priv_subnet_b_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_b_priv.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "priv_subnet_c_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_c_priv.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet_gateway.id
    }

  tags = {
    Name = "${var.network_name}_public_route_table"
  }
}

resource "aws_route_table_association" "pub_subnet_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_a_pub.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_subnet_b_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_b_pub.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_subnet_c_route_table_association" {
  subnet_id      = aws_subnet.subnet_az_c_pub.id
  route_table_id = aws_route_table.public_route_table.id
}
