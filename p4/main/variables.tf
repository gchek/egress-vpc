


variable "AWS_region"         {default = "us-west-2"}
variable "key_pair"           {default = "set-emea-oregon" }

variable "AWS_ASN_TGW"        {default = 64512}

/*================
VPN data
=================*/

variable "SDDC_ASN_VPN"           {default = 65000}
variable "SDDC_VPN_publicIP"      {}

variable "tunnels_preshared_key"  {} //see terraform.tfvars
variable "tunnel1_inside_cidr"    {default = "169.254.154.0/30"}
variable "tunnel2_inside_cidr"    {default = "169.254.154.4/30"}

/*================
Subnets IP ranges
=================*/
variable "My_subnets" {
  default = {

    SDDC_default          = "192.168.1.0/24"

    VPC100                = "172.100.0.0/16"
    Subnet10-vpc100-A     = "172.100.10.0/24"
    Subnet20-vpc100-B     = "172.100.20.0/24"

    VPC200                = "172.200.0.0/16"
    Subnet10-vpc200-A     = "172.200.10.0/24"
    Subnet20-vpc200-B     = "172.200.20.0/24"

    VPC-Egress            = "172.222.0.0/16"
    VPC-Egress-public-A   = "172.222.10.0/24"
    VPC-Egress-public-B   = "172.222.20.0/24"
    VPC-Egress-private-A  = "172.222.30.0/24"
    VPC-Egress-private-B  = "172.222.40.0/24"

  }
}
/*================
VM AMIs
=================*/

variable "VM_AMI"               { default = "ami-04590e7389a6e577c" } # Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon




