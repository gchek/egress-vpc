
/*================
Create VPCs
Create respective Internet Gateways
Create subnets
Create route tables
create security groups
=================*/
variable "vpc-egress_cidr"                {}
variable "vpc-egress-10-public-A"         {}
variable "vpc-egress-20-public-B"         {}
variable "vpc-egress-30-private-A"        {}
variable "vpc-egress-40-private-B"        {}

variable "SDDC_default"       {}

/*================
VPCs
=================*/

resource "aws_vpc" "egress-vpc" {
  // Apps VPC100
  cidr_block            = var.vpc-egress_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "Egress-VPC"
  }
}

/*===================
Subnets in EGRESS-VPC
====================*/

resource "aws_subnet" "vpc-egress-10-public-A" {
  vpc_id     = aws_vpc.egress-vpc.id
  cidr_block = var.vpc-egress-10-public-A
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "egress-vpc-10-public-A"
  }
}
resource "aws_subnet" "vpc-egress-20-public-B" {
  vpc_id     = aws_vpc.egress-vpc.id
  cidr_block = var.vpc-egress-20-public-B
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "egress-vpc-20-public-B"
  }
}

resource "aws_subnet" "vpc-egress-30-private-A" {
  vpc_id     = aws_vpc.egress-vpc.id
  cidr_block = var.vpc-egress-30-private-A
  availability_zone = data.aws_availability_zones.AZ.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "egress-vpc-30-private-A"
  }
}
resource "aws_subnet" "vpc-egress-40-private-B" {
  vpc_id     = aws_vpc.egress-vpc.id
  cidr_block = var.vpc-egress-40-private-B
  availability_zone = data.aws_availability_zones.AZ.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "egress-vpc-40-private-B"
  }
}

/*================
IGWs
=================*/
resource "aws_internet_gateway" "egress-igw" {
  vpc_id = aws_vpc.egress-vpc.id
  tags = {
    Name = "Egress-VPC-IGW"
  }
}
/*================
NAT Gateways
=================*/
resource "aws_eip" "NAT_A" {
  vpc      = true
  tags = {
    Name = "NAT EIP A"
  }
}
resource "aws_nat_gateway" "NAT_GW_A" {
  allocation_id = aws_eip.NAT_A.id
  subnet_id     = aws_subnet.vpc-egress-10-public-A.id
  tags = {
    Name = "NAT Gateway A"
  }
}

/*=============================*/

resource "aws_eip" "NAT_B" {
  vpc      = true
  tags = {
    Name = "NAT EIP B"
  }
}
resource "aws_nat_gateway" "NAT_GW_B" {
  allocation_id = aws_eip.NAT_B.id
  subnet_id     = aws_subnet.vpc-egress-20-public-B.id
  tags = {
    Name = "NAT Gateway B"
  }
}
/*=================================
Default Egress route table
==================================*/

resource "aws_default_route_table" "RT-Egress" {
  default_route_table_id = aws_vpc.egress-vpc.default_route_table_id
  tags = {
    Name = "RT-Egress"
  }
}
/*===========================================
Route Tables & subnets association VPC-Egress
============================================*/

resource "aws_route_table" "RT-Egress-public-A" {
  vpc_id = aws_vpc.egress-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.egress-igw.id
  }
  route {
    cidr_block = var.vpc100_cidr
    transit_gateway_id = var.TGW_id
  }
  route {
    cidr_block = var.vpc200_cidr
    transit_gateway_id = var.TGW_id
  }
  route {
    cidr_block = var.SDDC_default
    transit_gateway_id = var.TGW_id
  }

  tags = {
    Name = "RT-Egress-public-A"
  }
}
resource "aws_route_table_association" "vpc-egress-10-public-A" {
  subnet_id      = aws_subnet.vpc-egress-10-public-A.id
  route_table_id = aws_route_table.RT-Egress-public-A.id
}


resource "aws_route_table" "RT-Egress-public-B" {
  vpc_id = aws_vpc.egress-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.egress-igw.id
  }
  route {
    cidr_block = var.vpc100_cidr
    transit_gateway_id = var.TGW_id
  }
  route {
    cidr_block = var.vpc200_cidr
    transit_gateway_id = var.TGW_id
  }
  route {
    cidr_block = var.SDDC_default
    transit_gateway_id = var.TGW_id
  }

  tags = {
    Name = "RT-Egress-public-B"
  }
}
resource "aws_route_table_association" "vpc-egress-20-public-B" {
  subnet_id      = aws_subnet.vpc-egress-20-public-B.id
  route_table_id = aws_route_table.RT-Egress-public-B.id
}

resource "aws_route_table" "RT-Egress-private-A" {
  vpc_id = aws_vpc.egress-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GW_A.id
  }
  tags = {
    Name = "RT-Egress-private-A"
  }
}
resource "aws_route_table_association" "vpc-egress-30-private-A" {
  subnet_id      = aws_subnet.vpc-egress-30-private-A.id
  route_table_id = aws_route_table.RT-Egress-private-A.id
}

resource "aws_route_table" "RT-Egress-private-B" {
  vpc_id = aws_vpc.egress-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GW_B.id
  }
  tags = {
    Name = "RT-Egress-private-B"
  }
}
resource "aws_route_table_association" "vpc-egress-40-private-B" {
  subnet_id      = aws_subnet.vpc-egress-40-private-B.id
  route_table_id = aws_route_table.RT-Egress-private-B.id
}

/*==================
  SG-Egress
===================*/

resource "aws_security_group" "SG-VPC_Egress" {
  name    = "SG-VPC_Egress"
  vpc_id  = aws_vpc.egress-vpc.id
  tags = {
    Name = "SG-VPC_Egress"
  }
  #SSH, all PING and others
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all PING"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


/*=================================
Outputs variables for other modules
==================================*/

output "egress-vpc_id"               {value = aws_vpc.egress-vpc.id}
output "vpc-egress-10-public-A"      {value = aws_subnet.vpc-egress-10-public-A.id}
output "vpc-egress-20-public-B"      {value = aws_subnet.vpc-egress-20-public-B.id}
output "vpc-egress-30-private-A"     {value = aws_subnet.vpc-egress-30-private-A.id}
output "vpc-egress-40-private-B"     {value = aws_subnet.vpc-egress-40-private-B.id}
output "SG-VPC_Egress"               {value = aws_security_group.SG-VPC_Egress.id}


