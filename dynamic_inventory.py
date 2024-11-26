import boto3
import json
import subprocess
import sys

def install_dependencies():
    """Directly install boto3 and ansible."""
    print("Installing boto3...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "boto3"])

    print("Installing Ansible...")
    subprocess.check_call(["sudo", "yum", "install", "-y", "ansible"])

def get_subnet_ids_by_cidr(cidr_blocks):
    """Fetch subnet IDs for given CIDR blocks."""
    ec2 = boto3.client('ec2')
    subnet_ids = []
    for cidr in cidr_blocks:
        response = ec2.describe_subnets(Filters=[{'Name': 'cidr-block', 'Values': [cidr]}])
        for subnet in response['Subnets']:
            subnet_ids.append(subnet['SubnetId'])
    return subnet_ids

def get_instances(filters):
    """Fetch EC2 instances based on filters."""
    try:
        ec2 = boto3.client('ec2')
        response = ec2.describe_instances(Filters=filters)
        instances = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] == 'running':  # Only running instances
                    instances.append(instance)
        return instances
    except Exception as e:
        print(f"Error fetching instances: {e}")
        return []

def main():
    # Install necessary dependencies
    install_dependencies()

    # Define CIDR blocks for public subnet 3 and public subnet 4
    cidr_blocks = ['10.1.3.0/24', '10.1.4.0/24']
    
    # Get subnet IDs for these CIDR blocks
    subnet_ids = get_subnet_ids_by_cidr(cidr_blocks)

    # Update filters to include instances in these subnets
    instance_filters = [
        {'Name': 'subnet-id', 'Values': subnet_ids}
    ]

    instances = get_instances(instance_filters)
    inventory = {
        "all": {
            "hosts": {}
        },
        "webservers": {
            "hosts": {}
        }
    }

    for instance in instances:
        # Use PrivateIpAddress instead of PublicIpAddress
        ip_address = instance.get('PrivateIpAddress', 'N/A')  # Default to 'N/A' if no private IP
        tags = instance.get('Tags', [])
        hostname = next((tag['Value'] for tag in tags if tag['Key'] == 'Name'), 'Unknown')  # Default to 'Unknown' if no Name tag

        # Add the instance to the 'all' group
        inventory['all']['hosts'][hostname] = {"ansible_host": ip_address}

        # Add the instance to the 'webservers' group
        inventory['webservers']['hosts'][hostname] = None  # No additional variables for now

    # Save the inventory to a JSON file
    with open('inventory.json', 'w') as outfile:
        json.dump(inventory, outfile, indent=2)

    print("Inventory file generated successfully!")

if __name__ == '__main__':
    main()
