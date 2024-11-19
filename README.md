# Infrastructure_Project
         ___        ______     ____ _                 _  ___  
        / \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \ 
       / _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
      / ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
     /_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/ 
 ----------------------------------------------------------------- 

<!--Install terraform-->
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

<!--Replace your s3 bucket on all config files-->
/application/dev/network/config.tf
/application/staging/network/config.tf
/application/prod/network/config.tf

<!--Deploy dev VPC-->
cd application/dev/network/

terraform init
terraform plan
terraform apply -auto-approve

<!--Deploy staging VPC-->
cd ../../staging/network/

terraform init
terraform plan
terraform apply -auto-approve

<!--Deploy prod VPC-->
cd ../../prod/network/

terraform init
terraform plan
terraform apply -auto-approve

