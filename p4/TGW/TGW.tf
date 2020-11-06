variable "SDDC_default"             {}

variable "VPC100_id"                {}
variable "VPC100_cidr"              {}

variable "VPC200_id"                {}
variable "VPC200_cidr"              {}

variable "egress-vpc_id"            {}
variable "VPC-egress_cidr"          {}

variable "Subnet10-vpc100-A"        {}
variable "Subnet20-vpc100-B"        {}

variable "Subnet10-vpc200-A"        {}
variable "Subnet20-vpc200-B"        {}

variable "vpc-egress-10-public-A"   {}
variable "vpc-egress-20-public-B"   {}
variable "vpc-egress-30-private-A"  {}
variable "vpc-egress-40-private-B"  {}

variable "AWS_ASN_TGW"              {}
variable "SDDC_ASN_VPN"             {}
variable "SDDC_VPN_publicIP"        {}
variable "tunnels_preshared_key"    {}
variable "tunnel1_inside_cidr"      {}
variable "tunnel2_inside_cidr"      {}

/*===========================================
Create TGW and VPC attachments
============================================*/

resource "aws_ec2_transit_gateway" "TGW" {
  description     = "TGW"
  amazon_side_asn = var.AWS_ASN_TGW
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "TGW"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-attach-VPC100" {
  subnet_ids          = [var.Subnet10-vpc100-A, var.Subnet20-vpc100-B]
  transit_gateway_id  = aws_ec2_transit_gateway.TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.VPC100_id
  tags = {
    Name = "TGW-attach-VPC100"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-attach-VPC200" {
  subnet_ids          = [var.Subnet10-vpc200-A, var.Subnet20-vpc200-B]
  transit_gateway_id  = aws_ec2_transit_gateway.TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.VPC200_id
  tags = {
    Name = "TGW-attach-VPC200"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-attach-Egress" {
  subnet_ids          = [var.vpc-egress-30-private-A, var.vpc-egress-40-private-B]
  transit_gateway_id  = aws_ec2_transit_gateway.TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.egress-vpc_id
  tags = {
    Name = "TGW-attach-Egress-VPC"
  }
}

/*===========================================
Add VPN Site to site and TGW VPN attachment
============================================*/
// 1- Customer  GW (the  SDDC side)
resource "aws_customer_gateway" "VMC" {
  bgp_asn    = var.SDDC_ASN_VPN
  ip_address = var.SDDC_VPN_publicIP
  type       = "ipsec.1"
  tags = {
    Name = "VMC-Side-VPN"
  }
}
// 2- Build a VPN connection to TGW
resource "aws_vpn_connection" "RB_VPN" {
  customer_gateway_id = aws_customer_gateway.VMC.id
  transit_gateway_id  = aws_ec2_transit_gateway.TGW.id
  type                = aws_customer_gateway.VMC.type
  tunnel1_inside_cidr = var.tunnel1_inside_cidr
  tunnel2_inside_cidr = var.tunnel2_inside_cidr
  tunnel1_preshared_key = var.tunnels_preshared_key
  tunnel2_preshared_key = var.tunnels_preshared_key
  tags = {
    Name = "VPN to SDDC"
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "TGW_attach_SDDC" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpn_connection_id  = aws_vpn_connection.RB_VPN.id
}



/*===========================================
TGW Apps Route table Associations and routes
============================================*/
resource "aws_ec2_transit_gateway_route_table" "Apps_RT" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "Apps_RT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "Apps_RT_assoc-100" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-VPC100.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Apps_RT.id
}
resource "aws_ec2_transit_gateway_route_table_association" "Apps_RT_assoc-200" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Apps_RT.id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-VPC200.id
}
resource "aws_ec2_transit_gateway_route" "Apps_Default_route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-Egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Apps_RT.id
}
// Blackhole routes
resource "aws_ec2_transit_gateway_route" "Blackhole-100" {
  destination_cidr_block         = var.VPC100_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Apps_RT.id
}
resource "aws_ec2_transit_gateway_route" "Blackhole-200" {
  destination_cidr_block         = var.VPC200_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Apps_RT.id
}

/*=============================================
TGW Egress Route table Associations and routes
==============================================*/
resource "aws_ec2_transit_gateway_route_table" "Egress_RT" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "Egress_RT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "Egress_RT-Assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-Egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Egress_RT.id
}
resource "aws_ec2_transit_gateway_route" "VPC100" {
  destination_cidr_block = var.VPC100_cidr
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-VPC100.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Egress_RT.id
}
resource "aws_ec2_transit_gateway_route" "VPC200" {
  destination_cidr_block = var.VPC200_cidr
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-VPC200.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Egress_RT.id
}
resource "aws_ec2_transit_gateway_route" "SDDC" {
  destination_cidr_block = var.SDDC_default
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpn_attachment.TGW_attach_SDDC.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Egress_RT.id
}

/*=============================================
TGW SDDC Route table Associations and routes
==============================================*/
resource "aws_ec2_transit_gateway_route_table" "SDDC_RT" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "SDDC_RT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "SDDC_RT-Assoc" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpn_attachment.TGW_attach_SDDC.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.SDDC_RT.id
}

resource "aws_ec2_transit_gateway_route" "SDDC_Default_route" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGW-attach-Egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.SDDC_RT.id
}
// Blackhole routes
resource "aws_ec2_transit_gateway_route" "SDDC_Blackhole-100" {
  destination_cidr_block         = var.VPC100_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.SDDC_RT.id
}
resource "aws_ec2_transit_gateway_route" "SDDC_Blackhole-200" {
  destination_cidr_block         = var.VPC200_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.SDDC_RT.id
}

/*================
Outputs variables
=================*/

output "TGW_id"         {value = aws_ec2_transit_gateway.TGW.id}
output "Tunnel1_IP"     { value = aws_vpn_connection.RB_VPN.tunnel1_address }
output "Tunnel2_IP"     { value = aws_vpn_connection.RB_VPN.tunnel2_address }

