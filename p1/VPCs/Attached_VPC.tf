
/*================
Create VPCs
Create respective Internet Gateways
Create subnets
Create route tables
create security groups
=================*/

variable "VPC_Att_cidr"              {}
variable "Subnet10-Att_vpc"          {}
variable "Subnet20-Att_vpc"          {}

variable "region"                    {}

/*================
VPCs
=================*/

resource "aws_vpc" "Att_vpc" {
  cidr_block            = var.VPC_Att_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "Attached_VPC"
  }
}

/*=============================
Subnets in attached VPC
==============================*/
# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "Subnet10-Att_vpc" {
  vpc_id     = aws_vpc.Att_vpc.id
  cidr_block = var.Subnet10-Att_vpc
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "Subnet10-Att_vpc"
  }
}
resource "aws_subnet" "Subnet20-Att_vpc" {
  vpc_id     = aws_vpc.Att_vpc.id
  cidr_block = var.Subnet20-Att_vpc
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "Subnet20-Att_vpc"
  }
}

/*================
IGWs
=================*/
resource "aws_internet_gateway" "Att_vpc-IGW" {
  vpc_id = aws_vpc.Att_vpc.id
  tags = {
    Name = "IGW Attached VPC"
  }
}


/*========================
default route table
=========================*/

resource "aws_default_route_table" "Att_vpc-RT" {
  default_route_table_id = aws_vpc.Att_vpc.default_route_table_id

  lifecycle {
    ignore_changes = [route] # ignore any manually or ENI added routes
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Att_vpc-IGW.id
  }

  tags = {
    Name = "RT-Att_vpc"
  }
}



/*================================
Route Table association for VPC201
=================================*/

resource "aws_route_table_association" "Att_vpc_10" {
  subnet_id      = aws_subnet.Subnet10-Att_vpc.id
  route_table_id = aws_default_route_table.Att_vpc-RT.id
}


/*================
Security Groups
=================*/

resource "aws_security_group" "SG-Att_vpc" {
  name    = "SG-Att_vpc"
  vpc_id  = aws_vpc.Att_vpc.id
  tags = {
    Name = "SG-Att_vpc"
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
  ingress {
    description = "Allow MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow iPERF3"
    from_port = 5201
    to_port = 5201
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_default_security_group" "default" {

  vpc_id = aws_vpc.Att_vpc.id

  ingress {
    description = "Default SG for VPC201"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress{
     description = "Include EC2 SG in VPC201 default SG"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     security_groups = [aws_security_group.SG-Att_vpc.id]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Default VPC201-SG"
  }
}

/*==================
  S3 VPC end point
===================*/
resource "aws_vpc_endpoint" "s3" {
 vpc_id          = aws_vpc.Att_vpc.id
 service_name    = "com.amazonaws.${var.region}.s3"
 route_table_ids = [aws_default_route_table.Att_vpc-RT.id]
}


/*===================================
  Outputs variables for other modules
====================================*/
output "Att_vpc_id"               {value = aws_vpc.Att_vpc.id}
output "Subnet10-Att_vpc_id"      {value = aws_subnet.Subnet10-Att_vpc.id}
output "SG-Att_vpc_id"            {value = aws_security_group.SG-Att_vpc.id}





