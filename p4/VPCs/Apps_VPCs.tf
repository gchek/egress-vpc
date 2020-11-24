
/*================
Create VPCs
Create respective Internet Gateways
Create subnets
Create route tables
create security groups
=================*/


variable "vpc100_cidr"              {}
variable "Subnet10-vpc100-A"        {}
variable "Subnet20-vpc100-B"        {}

variable "vpc200_cidr"              {}
variable "Subnet10-vpc200-A"        {}
variable "Subnet20-vpc200-B"        {}

variable "TGW_id"                   {}

/*================
VPCs
=================*/

resource "aws_vpc" "vpc100" {
  // Apps VPC100
  cidr_block            = var.vpc100_cidr
  tags = {
    Name = "APPS_VPC100"
  }
}
resource "aws_vpc" "vpc200" {
  // Apps VPC200
  cidr_block            = var.vpc200_cidr
  tags = {
    Name = "APPS_VPC200"
  }
}

/*================
Subnets in VPC100
=================*/
# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "Subnet10-vpc100-A" {
  vpc_id     = aws_vpc.vpc100.id
  cidr_block = var.Subnet10-vpc100-A
  availability_zone = data.aws_availability_zones.AZ.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Subnet10-vpc100-A"
  }
}
resource "aws_subnet" "Subnet20-vpc100-B" {
  vpc_id     = aws_vpc.vpc100.id
  cidr_block = var.Subnet20-vpc100-B
  availability_zone = data.aws_availability_zones.AZ.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Subnet20-vpc100-B"
  }
}

/*================
Subnets in VPC200
=================*/

resource "aws_subnet" "Subnet10-vpc200-A" {
  vpc_id     = aws_vpc.vpc200.id
  cidr_block = var.Subnet10-vpc200-A
  availability_zone = data.aws_availability_zones.AZ.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Subnet10-vpc200-A"
  }
}
resource "aws_subnet" "Subnet20-vpc200-B" {
  vpc_id     = aws_vpc.vpc200.id
  cidr_block = var.Subnet20-vpc200-B
  availability_zone = data.aws_availability_zones.AZ.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Subnet20-vpc200-B"
  }
}

/*====================================
Route Table & subnet association 100-200
======================================*/

resource "aws_route_table_association" "subnet10-vpc100" {
  subnet_id      = aws_subnet.Subnet10-vpc100-A.id
  route_table_id = aws_default_route_table.RT-100.id
}
resource "aws_route_table_association" "subnet20-vpc100" {
  subnet_id      = aws_subnet.Subnet20-vpc100-B.id
  route_table_id = aws_default_route_table.RT-100.id
}
resource "aws_route_table_association" "subnet10-vpc200" {
  subnet_id      = aws_subnet.Subnet10-vpc200-A.id
  route_table_id = aws_default_route_table.RT-200.id
}
resource "aws_route_table_association" "subnet20-vpc200" {
  subnet_id      = aws_subnet.Subnet20-vpc200-B.id
  route_table_id = aws_default_route_table.RT-200.id
}


/*============================
Default route tables 100-200
=============================*/

resource "aws_default_route_table" "RT-100" {
  lifecycle {
    ignore_changes = [route] # ignore any manually added routes
  }
  default_route_table_id = aws_vpc.vpc100.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.TGW_id
  }
  tags = {
    Name = "RT-100"
  }
}

resource "aws_default_route_table" "RT-200" {
  lifecycle {
    ignore_changes = [route] # ignore any manually added routes
  }
  default_route_table_id = aws_vpc.vpc200.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.TGW_id
  }
  tags = {
    Name = "RT-200"
  }
}

/*==================
  SG-100
===================*/

resource "aws_security_group" "SG-VPC100" {
  name    = "SG-VPC100"
  vpc_id  = aws_vpc.vpc100.id
  tags = {
    Name = "SG-VPC100"
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

/*==================
  SG-200
===================*/

resource "aws_security_group" "SG-VPC200" {
  name    = "SG-VPC200"
  vpc_id  = aws_vpc.vpc200.id
  tags = {
    Name = "SG-VPC200"
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



/*===================================
  Outputs variables for other modules
====================================*/
output "VPC100_id"              {value = aws_vpc.vpc100.id}
output "Subnet10-vpc100-A"      {value = aws_subnet.Subnet10-vpc100-A.id}
output "Subnet20-vpc100-B"      {value = aws_subnet.Subnet20-vpc100-B.id}
output "SG-VPC100"              {value = aws_security_group.SG-VPC100.id}


output "VPC200_id"              {value = aws_vpc.vpc200.id}
output "Subnet10-vpc200-A"      {value = aws_subnet.Subnet10-vpc200-A.id}
output "Subnet20-vpc200-B"      {value = aws_subnet.Subnet20-vpc200-B.id}
output "SG-VPC200"              {value = aws_security_group.SG-VPC200.id}






