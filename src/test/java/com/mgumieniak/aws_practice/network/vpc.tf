resource "aws_vpc" "vpc" {
  cidr_block = "172.17.0.0/16"
  tags = {
    Name = "${var.network_name}_vpc"
    environment = var.environment
  }
}
