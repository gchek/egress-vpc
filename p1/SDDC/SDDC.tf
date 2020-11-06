variable "my_org_id"            {}
variable "SDDC_Mngt"            {}
variable "SDDC_default"         {}
variable "Att_vpc_subnet_id"    {}
variable "region"               {}
variable "AWS_account"          {}

/*==========================
Get ORG and AWS account info
==========================*/
//data "vmc_org" "my_org" {
//  id = ???
//}
data "vmc_connected_accounts" "my_accounts" {
  account_number = var.AWS_account
}

/*==========================
Create SDDC 1 node
==========================*/
resource "vmc_sddc" "Terraform_SDDC1" {
    lifecycle {
        ignore_changes = [edrs_policy_type, enable_edrs]
    }
    sddc_name           = "Terraform_SDDC"
    vpc_cidr            = var.SDDC_Mngt
    num_host            = 1
    provider_type       = "AWS"
    region              = replace(upper(var.region), "-", "_")
    vxlan_subnet        = var.SDDC_default
    delay_account_link  = false
    skip_creating_vxlan = false
    host_instance_type  = "I3_METAL"
    sso_domain          = "vmc.local"
    deployment_type     = "SingleAZ"
    sddc_type           = "1NODE"

    account_link_sddc_config {
        customer_subnet_ids  = [var.Att_vpc_subnet_id]
        connected_account_id = data.vmc_connected_accounts.my_accounts.id
    }
    timeouts {
        create = "300m"
        update = "300m"
        delete = "180m"
    }
}


/*=======================
Outputs for other modules
========================*/
output "proxy_url"          {value = trimsuffix(trimprefix(vmc_sddc.Terraform_SDDC1.nsxt_reverse_proxy_url, "https://"), "/sks-nsxt-manager")}
output "vc_url"             {value = trimsuffix(trimprefix(vmc_sddc.Terraform_SDDC1.vc_url, "https://"), "/")}
output "cloud_username"     {value = vmc_sddc.Terraform_SDDC1.cloud_username}
output "cloud_password"     {value = vmc_sddc.Terraform_SDDC1.cloud_password}
output "vc_public_IP"       {value = replace(trimsuffix(trimprefix(vmc_sddc.Terraform_SDDC1.vc_url, "https://vcenter.sddc-"), ".vmwarevmc.com/"), "-", ".")}

