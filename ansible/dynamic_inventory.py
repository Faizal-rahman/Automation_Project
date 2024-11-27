#!/usr/bin/env python

import subprocess
import sys

# Install dependencies
def install_dependencies():
    required_packages = ["boto3", "ansible"]
    for package in required_packages:
        try:
            # Install the package using pip
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"{package} installed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to install {package}. Error: {e}")
            sys.exit(1)

# Install dependencies before importing
install_dependencies()

# Import dependencies
import boto3
import json

# Create a session using your AWS credentials
ec2_client = boto3.client('ec2')

# CIDR blocks to search for
cidr_blocks = ['10.1.3.0/24', '10.1.4.0/24']

# Initialize the inventory
inventory = {
    "all": {
        "hosts": {}
    },
    "webservers": {
        "hosts": {}
    }
}

# Function to find the subnets based on CIDR block
def find_subnet_ids(cidr_blocks):
    subnet_ids = []
    for cidr_block in cidr_blocks:
        # Get the subnets matching the CIDR block
        response = ec2_client.describe_subnets(
            Filters=[{
                'Name': 'cidrBlock',
                'Values': [cidr_block]
            }]
        )
        for subnet in response['Subnets']:
            subnet_ids.append(subnet['SubnetId'])
    return subnet_ids

# Function to find instances based on subnet ids
def find_instances_in_subnets(subnet_ids):
    instances = ec2_client.describe_instances(
        Filters=[{
            'Name': 'subnet-id',
            'Values': subnet_ids
        }]
    )
    return instances

# Find subnet IDs for the given CIDR blocks
subnet_ids = find_subnet_ids(cidr_blocks)
print(f"Subnet IDs obtained: {subnet_ids}")

# Find instances in the subnets
instances = find_instances_in_subnets(subnet_ids)

# Iterate through instances and use InstanceId as the hostname
for reservation in instances['Reservations']:
    for instance in reservation['Instances']:
        # Using InstanceId directly as hostname
        instance_id = instance['InstanceId']
        ip_address = instance.get('PublicIpAddress')  # Safeguard if no public IP exists
        
        # Add instance info to inventory under its InstanceId
        inventory["all"]["hosts"][instance_id] = {
            "ansible_host": ip_address
        }
        
        # Add to 'webservers' group if the instance is tagged as a webserver
        if 'webserver' in [tag['Value'] for tag in instance.get('Tags', [])]:
            inventory["webservers"]["hosts"][instance_id] = None

# Output the inventory in JSON format
inventory_filename = "inventory.json"
with open(inventory_filename, "w") as f:
    json.dump(inventory, f, indent=2)

print(f"Inventory file generated successfully! Saved as {inventory_filename}")
