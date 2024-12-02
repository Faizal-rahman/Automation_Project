# Infrastructure_Project
<<<<<<< HEAD
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


<!-- Deploy dev load balancer, EC2 instances, and auto scaling group. -->
cd ../../dev/webservers/
ssh-keygen -t rsa -f sshkey
terraform init
terraform plan
terraform apply -auto-approve

<!-- Deploy staging load balancer, EC2 instances, and auto scaling group. -->
cd ../../staging/webservers/
ssh-keygen -t rsa -f sshkey
terraform init
terraform plan
terraform apply -auto-approve

<!-- Deploy prod load balancer, EC2 instances, and auto scaling group. -->
cd ../../prod/webservers/
ssh-keygen -t rsa -f sshkey
terraform init
terraform plan
terraform apply -auto-approve
=======

dynamic_inventory.py #Python script to generate a dynamic inventory with only webserver 3 and webserver 4

cd into the folder containing the script. 

///

sudo yum install python3-pip # to install pip 
pip install boto3 # to install boto3 for python to interact with amazon
python dynamic_inventory.py # to run the script  

///

the script will generate a output.json file which will be used as inventory file

After that in playbook change the environment accordingly, so that in the static webpage it displays the environment correctly.

install ansible in host machine 

///

sudo apt-get update
sudo apt-get install ansible

///

Run the playbook

///
ansible-playbook -i output.json playbook.yaml
///
>>>>>>> Ansible_Faizal

///
#Testing github actions
