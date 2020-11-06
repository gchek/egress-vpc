/*================
Outputs from Various Module
=================*/

output "sddc_subnet"            {value = module.VPCs.Subnet10-Att_vpc_id}
output "proxy_url"              {value = module.SDDC.proxy_url}
output "vc_url"                 {value = module.SDDC.vc_url}
output "vc_public_IP"           {value = module.SDDC.vc_public_IP}
output "cloud_username"         {value = module.SDDC.cloud_username}
output "cloud_password"         {
  sensitive = true
  value = module.SDDC.cloud_password
}




