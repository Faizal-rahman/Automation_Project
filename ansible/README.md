# Infrastructure_Project

dynamic_inventory.py #Python script to generate a dynamic inventory with only ip addresses of instances which are in public subnet 3 and public subnet 4.

cd into the folder containing the script. 

///

python dynamic_inventory.py # to run the script  

///

the script will install boto3 and ansible generate a output.json file which will be used as inventory file

After that in playbook change the environment accordingly, so that in the static webpage it displays the environment correctly.

Run the playbook

///
ansible-playbook -i output.json playbook.yaml
///
