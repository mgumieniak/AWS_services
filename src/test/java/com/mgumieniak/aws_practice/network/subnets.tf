data "aws_availability_zones" "az_zones" {
  state = "available"
  all_availability_zones = true
  filter {
    name   = "region-name"
    values = ["eu-west-1"]
  }
}

resource "aws_subnet" "subnet_az_a_priv" {

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.0.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[0]

  tags = {
    Name = "${var.network_name}_subnet_az_a_priv"
    environment = var.environment
  }
}

resource "aws_subnet" "subnet_az_a_pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.8.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.network_name}_subnet_az_a_pub"
    environment = var.environment
  }
}

resource "aws_subnet" "subnet_az_b_priv" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.16.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[1]

  tags = {
    Name = "${var.network_name}_subnet_az_b_priv"
    environment = var.environment
  }
}

resource "aws_subnet" "subnet_az_b_pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.24.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.network_name}_subnet_az_b_pub"
    environment = var.environment
  }
}

resource "aws_subnet" "subnet_az_c_priv" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.32.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[2]

  tags = {
    Name = "${var.network_name}_subnet_az_c_priv"
    environment = var.environment
  }
}

resource "aws_subnet" "subnet_az_c_pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.17.40.0/21"
  availability_zone_id = data.aws_availability_zones.az_zones.zone_ids[2]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.network_name}_subnet_az_c_pub"
    environment = var.environment
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_az_a_priv.id, aws_subnet.subnet_az_b_priv.id, aws_subnet.subnet_az_c_priv.id]

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }


  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.network_name}_priv_nacl"
  }
}
