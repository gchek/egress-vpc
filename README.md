# egress-vpc
Terraform for egress-vpc
Make sure your AWS account is linked to your ORG
- run Cloud Formation template if not


## Variables
Some variables need to be defined before we start. 

Use `deploy-lab-copy.sh` to set the proper credentials in `deploy-lab.sh` 
```
deploy-lab.sh
```
 - Org ID
    -   long format like `2a8ac0ba-c93d-xxxx-xxxx-7dc9918beaa5`
 - API Token
    -   Your API Token
 - AWS Account
    -   AWS Account: `614xxxxxxx43`
 - AWS Access Key

 - AWS Secret Key
  
 #### 1 - Terraform Phase 1 (AWS)
```
p1/main/variables.tf
```
 - `variable "AWS_region"     {default = "us-west-1"}`

  
  
 AWS public keys: 
  
  We are deploying a TKG EC2 as our CLI - make sure the AWS public key has 400 permissions and it's coming from the SAME account you deployed the AWS infrastructure.
  
 #### 2 - Terraform Phase 2 (NSXT)
```
p2/main/variables.tf
```



## Deploy lab
```text
source deploy-lab.sh
```
1 - Confirm ORG and AWS parameters
 
2 - (p1) SDDC deployment
 - outputs are printed
 > pause (press Enter or ^c)
 
3 - (p2) NSXT 
 - FW rules
 > pause (press Enter or ^c)
 

