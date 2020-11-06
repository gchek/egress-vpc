

variable "key_pair"               {}
variable "VM-AMI"                 {}


// VPC 100
variable "Subnet10-vpc100-A"      {}
variable "Subnet10-vpc100-Abase"  {}
variable "Subnet20-vpc100-B"      {}
variable "Subnet20-vpc100-Bbase"  {}
variable "SG-VPC100"              {}

//VPC200
variable "Subnet10-vpc200-A"      {}
variable "Subnet10-vpc200-Abase"  {}
variable "Subnet20-vpc200-B"      {}
variable "Subnet20-vpc200-Bbase"  {}
variable "SG-VPC200"              {}

// VPC-Egress
variable "Subnet-10-public-A"     {}
variable "Subnet-10-public-Abase" {}
variable "SG-VPC_Egress"          {}


/*=====================================
EC2 Instance as jump-host in Egress VPC
======================================*/
resource "aws_network_interface" "VM1-Egress-Eth0" {
  subnet_id                     = var.Subnet-10-public-A
  security_groups               = [var.SG-VPC_Egress]
  private_ips                   = [cidrhost(var.Subnet-10-public-Abase, 100)]
}
resource "aws_instance" "VM1-Egress" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-Egress-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  tags = {
    Name = "VM1-VPC-Egress"
  }
}

/*=====================================
EC2 Instances in VPC 100
======================================*/
resource "aws_network_interface" "VM1-100-Eth0" {
  subnet_id                     = var.Subnet10-vpc100-A
  security_groups               = [var.SG-VPC100]
  private_ips                   = [cidrhost(var.Subnet10-vpc100-Abase, 100)]
}
resource "aws_instance" "VM1-100" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-100-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  tags = {
    Name = "VM1-VPC100"
  }
}
resource "aws_network_interface" "VM2-100-Eth0" {
  subnet_id                     = var.Subnet20-vpc100-B
  security_groups               = [var.SG-VPC100]
  private_ips                   = [cidrhost(var.Subnet20-vpc100-Bbase, 100)]
}
resource "aws_instance" "VM2-100" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM2-100-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  tags = {
    Name = "VM2-VPC100"
  }
}

/*=====================================
EC2 Instances in VPC 200
======================================*/
resource "aws_network_interface" "VM1-200-Eth0" {
  subnet_id                     = var.Subnet10-vpc200-A
  security_groups               = [var.SG-VPC200]
  private_ips                   = [cidrhost(var.Subnet10-vpc200-Abase, 100)]
}
resource "aws_instance" "VM1-200" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-200-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  tags = {
    Name = "VM1-VPC200"
  }
}
resource "aws_network_interface" "VM2-200-Eth0" {
  subnet_id                     = var.Subnet20-vpc200-B
  security_groups               = [var.SG-VPC200]
  private_ips                   = [cidrhost(var.Subnet20-vpc200-Bbase, 100)]
}
resource "aws_instance" "VM2-200" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM2-200-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  tags = {
    Name = "VM2-VPC200"
  }
}
/*================
Outputs variables for other modules to use
=================*/

//output "EC2_IP"           {value = aws_instance.VM1.public_ip}
output "EC2_JumpHost"     {value = aws_instance.VM1-Egress.public_ip }

