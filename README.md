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

<!--Replace your s3 bucket on config files-->
/application/network/config.tf

<!--Deploy VPC-->
cd application/network/

terraform init
terraform plan
terraform apply -auto-approve


<!-- Deploy  load balancer, EC2 instances, and auto scaling group. -->
cd ../../webservers/
ssh-keygen -t rsa -f sshkey
terraform init
terraform plan
terraform apply -auto-approve

<!--Ansible -->

cd into ansible folder 

<!--Python script to generate a dynamic inventory with only ip addresses of instances which are in public subnet 3 and public subnet 4.-->
dynamic_inventory.py 


cd into the folder containing the script. 

<!-- to run the script-->
python dynamic_inventory.py 
  


<!--the script will install boto3 and ansible generate a inventory.json file which will be used as inventory file-->

After that in playbook change the environment accordingly, so that in the static webpage it displays the environment correctly.

Run the playbook

///
ansible-playbook -i inventory.json playbook.yaml
///
