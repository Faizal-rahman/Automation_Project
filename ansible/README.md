# Infrastructure_Project

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
