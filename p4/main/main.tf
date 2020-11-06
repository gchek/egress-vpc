


provider "aws" {
  region    = var.AWS_region
}


terraform {
  backend "local" {
    path = "../../phase4.tfstate"
  }
}

/*================
Create AWS VPCs
The VPCs and subnets CIDR are set in "variables.tf" file
=================*/
module "VPCs" {
  source = "../VPCs"

  SDDC_default              = var.My_subnets["SDDC_default"]

  vpc100_cidr               = var.My_subnets["VPC100"]
  Subnet10-vpc100-A         = var.My_subnets["Subnet10-vpc100-A"]
  Subnet20-vpc100-B         = var.My_subnets["Subnet20-vpc100-B"]

  vpc200_cidr               = var.My_subnets["VPC200"]
  Subnet10-vpc200-A         = var.My_subnets["Subnet10-vpc200-A"]
  Subnet20-vpc200-B         = var.My_subnets["Subnet20-vpc200-B"]

  vpc-egress_cidr           = var.My_subnets["VPC-Egress"]
  vpc-egress-10-public-A    = var.My_subnets["VPC-Egress-public-A"]
  vpc-egress-20-public-B    = var.My_subnets["VPC-Egress-public-B"]
  vpc-egress-30-private-A   = var.My_subnets["VPC-Egress-private-A"]
  vpc-egress-40-private-B   = var.My_subnets["VPC-Egress-private-B"]

  TGW_id                    = module.TGW.TGW_id

}
/*================
Create TGW
=================*/

module "TGW" {
  source = "../TGW"

  SDDC_default            = var.My_subnets["SDDC_default"]

  VPC100_id               = module.VPCs.VPC100_id
  VPC100_cidr             = var.My_subnets["VPC100"]

  VPC200_id               = module.VPCs.VPC200_id
  VPC200_cidr             = var.My_subnets["VPC200"]

  egress-vpc_id           = module.VPCs.egress-vpc_id
  VPC-egress_cidr         = var.My_subnets["VPC-Egress"]

  Subnet10-vpc100-A       = module.VPCs.Subnet10-vpc100-A
  Subnet20-vpc100-B       = module.VPCs.Subnet20-vpc100-B

  Subnet10-vpc200-A       = module.VPCs.Subnet10-vpc200-A
  Subnet20-vpc200-B       = module.VPCs.Subnet20-vpc200-B

  vpc-egress-10-public-A  = module.VPCs.vpc-egress-10-public-A
  vpc-egress-20-public-B  = module.VPCs.vpc-egress-20-public-B
  vpc-egress-30-private-A = module.VPCs.vpc-egress-30-private-A
  vpc-egress-40-private-B = module.VPCs.vpc-egress-40-private-B

  AWS_ASN_TGW             = var.AWS_ASN_TGW
  SDDC_ASN_VPN            = var.SDDC_ASN_VPN
  SDDC_VPN_publicIP       = var.SDDC_VPN_publicIP
  tunnels_preshared_key   = var.tunnels_preshared_key
  tunnel1_inside_cidr     = var.tunnel1_inside_cidr
  tunnel2_inside_cidr     = var.tunnel2_inside_cidr

}

/*================
Create EC2s
=================*/
module "EC2s" {
  source = "../EC2s"

  VM-AMI                = var.VM_AMI
  key_pair              = var.key_pair

  // VPC100
  Subnet10-vpc100-A     = module.VPCs.Subnet10-vpc100-A
  Subnet10-vpc100-Abase = var.My_subnets["Subnet10-vpc100-A"]
  Subnet20-vpc100-B     = module.VPCs.Subnet20-vpc100-B
  Subnet20-vpc100-Bbase = var.My_subnets["Subnet20-vpc100-B"]
  SG-VPC100             = module.VPCs.SG-VPC100

  // VPC200
  Subnet10-vpc200-A     = module.VPCs.Subnet10-vpc200-A
  Subnet10-vpc200-Abase = var.My_subnets["Subnet10-vpc200-A"]
  Subnet20-vpc200-B     = module.VPCs.Subnet20-vpc200-B
  Subnet20-vpc200-Bbase = var.My_subnets["Subnet20-vpc200-B"]
  SG-VPC200             = module.VPCs.SG-VPC200

  // VPC-Egress
  Subnet-10-public-A     = module.VPCs.vpc-egress-10-public-A
  Subnet-10-public-Abase = var.My_subnets["VPC-Egress-public-A"]
  SG-VPC_Egress          = module.VPCs.SG-VPC_Egress

}




