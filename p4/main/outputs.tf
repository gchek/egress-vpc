/*================
Outputs from Various Module
=================*/

output "EC2_JumpHost"           { value = module.EC2s.EC2_JumpHost}
output "VPN_tunnel1_IP"         { value = module.TGW.Tunnel1_IP }
output "VPN_tunnel2_IP"         { value = module.TGW.Tunnel2_IP }



