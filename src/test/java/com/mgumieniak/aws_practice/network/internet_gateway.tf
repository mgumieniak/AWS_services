resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.network_name}_internet_gateway"
    environment = var.environment
  }
}
