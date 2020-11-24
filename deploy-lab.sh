#!/usr/bin/env bash

clear
echo -e "\033[1m"   #Bold ON
echo " ==========================="
echo "     VMC deployment"
echo " ==========================="
echo "===== Set Credentials ============="
echo -e "\033[0m"   #Bold OFF

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TF_VAR_my_org_id
unset TF_VAR_vmc_token
unset TF_VAR_AWS_account
unset TF_VAR_host
unset VM1_DNS

DEF_ORG_ID="7421a286-xxxxxxxxxxxxxxxd75fb5"
#read -p "Enter your ORG ID (long format) [default=$DEF_ORG_ID]: " TF_VAR_my_org_id
TF_VAR_my_org_id="${TF_VAR_my_org_id:-$DEF_ORG_ID}"
#echo ".....Exporting $TF_VAR_my_org_id"
export TF_VAR_my_org_id=$TF_VAR_my_org_id
#echo ""

DEF_TOKEN="gCs8WlleUW3chxxxxxxxxxxxxxxxxxxxxxxxOV0QXxBwiWkfZVD6"
#read -p "Enter your VMC API token [default=$DEF_TOKEN]: " TF_VAR_vmc_token
TF_VAR_vmc_token="${TF_VAR_vmc_token:-$DEF_TOKEN}"
#echo ".....Exporting $TF_VAR_vmc_token"
export TF_VAR_vmc_token=$TF_VAR_vmc_token
#echo ""

ACCOUNT="xxxxxxxxxxxxx"6
#read -p "Enter your AWS Account [default=$ACCOUNT]: " TF_VAR_AWS_account
TF_VAR_AWS_account="${TF_VAR_AWS_account:-$ACCOUNT}"
#echo ".....Exporting $TF_VAR_AWS_account"
export TF_VAR_AWS_account=$TF_VAR_AWS_account
#echo ""

ACCESS="AKIxxxxxxxxxxxxxUZ76"
#read -p "Enter your AWS Access Key [default=$ACCESS]: " TF_VAR_access_key
TF_VAR_access_key="${TF_VAR_access_key:-$ACCESS}"
#echo ".....Exporting $TF_VAR_access_key"
export AWS_ACCESS_KEY_ID=$TF_VAR_access_key
#echo ""

SECRET="7M/qnxxxxxxxxxxxxxxxxxrDDd67Qx"
#read -p "Enter your AWS Secret Key [default=$SECRET]: " TF_VAR_secret_key
TF_VAR_secret_key="${TF_VAR_secret_key:-$SECRET}"
#echo ".....Exporting $TF_VAR_secret_key"
export AWS_SECRET_ACCESS_KEY=$TF_VAR_secret_key

#----------------------------------
read  -p $'Press enter to continue (^C to stop)...\n'

echo -e "\033[1m"   #Bold ON
echo "===== PHASE 1: Creating SDDC ==========="
echo -e "\033[0m"   #Bold OFF
cd ./p1/main
terraform init
terraform apply
cd ../../
#----------------------------------

export TF_VAR_host=$(terraform output -state=./phase1.tfstate proxy_url)

read  -p $'Press enter to continue (^C to stop)...\n'
cd ./p2/main
terraform  init

echo -e "\033[1m"   #Bold ON
echo "===== PHASE 2: Networking and Security ==========="
echo -e "\033[0m"   #Bold OFF

terraform apply
cd ../..
#----------------------------------

read  -p $'Press enter to continue (^C to stop)...\n'
echo -e "\033[1m"   #Bold ON
echo "===== PHASE 3: Create Content Lib and deploy VM  ==========="
echo -e "\033[0m"   #Bold OFF
cd ./p3/main
terraform  init
terraform apply
cd ../..

#----------------------------------

read  -p $'Press enter to continue (^C to stop)...\n'
echo -e "\033[1m"   #Bold ON
echo "===== PHASE 4: Egress VPC ==========="
echo -e "\033[0m"   #Bold OFF

read -p "Enter your SDDC VPN Public IP: " TF_VAR_SDDC_VPN_publicIP
echo ".....Exporting $TF_VAR_SDDC_VPN_publicIP"
export TF_VAR_SDDC_VPN_publicIP=$TF_VAR_SDDC_VPN_publicIP
echo ""
cd ./p4/main
terraform  init
terraform apply
cd ../../

#----------------------------------
