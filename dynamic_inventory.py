import boto3
import json

def get_subnet_ids_by_cidr(cidr_blocks):
    ec2 = boto3.client('ec2')
    subnet_ids = []
    for cidr in cidr_blocks:
        response = ec2.describe_subnets(Filters=[{'Name': 'cidr-block', 'Values': [cidr]}])
        for subnet in response['Subnets']:
            subnet_ids.append(subnet['SubnetId'])
    return subnet_ids

def get_instances(filters):
    try:
        ec2 = boto3.client('ec2')
        response = ec2.describe_instances(Filters=filters)
        instances = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] == 'running':
                    instances.append(instance)
        return instances
    except Exception as e:
        print(f"Error fetching instances: {e}")
        return []

def main():
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
            "hosts": []
        },
        "webservers": {
            "hosts": []
        }
    }

    for instance in instances:
        ip_address = instance.get('PublicIpAddress', 'N/A')  # Default to 'N/A' if no public IP
        tags = instance.get('Tags', [])
        hostname = next((tag['Value'] for tag in tags if tag['Key'] == 'Name'), 'Unknown')  # Default to 'Unknown' if no Name tag

        inventory['all']['hosts'].append(hostname)
        inventory['webservers']['hosts'].append(hostname)
        inventory[hostname] = {'ansible_host': ip_address}

    with open('inventory.json', 'w') as outfile:
        json.dump(inventory, outfile, indent=2)

if __name__ == '__main__':
    main()
