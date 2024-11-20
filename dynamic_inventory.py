import boto3
import json

def get_instances(filters):
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(Filters=filters)
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            if instance['State']['Name'] == 'running':
                instances.append(instance)
    return instances

def main():
    # Filter for instances with tags containing "WebServer3" or "WebServer4"
    filters = [
        {'Name': 'tag:Name', 'Values': ['*WebServer3*', '*WebServer4*']}
    ]

    instances = get_instances(filters)
    inventory = {
        "all": {
            "hosts": []
        },
        "webservers": {
            "hosts": []
        }
    }

    for instance in instances:
        ip_address = instance['PublicIpAddress']
        hostname = instance['Tags'][0]['Value']
        inventory['all']['hosts'].append(hostname)
        inventory['webservers']['hosts'].append(hostname)
        inventory[hostname] = {'ansible_host': ip_address}

    # Write inventory to JSON file
    with open('inventory.json', 'w') as outfile:
        json.dump(inventory, outfile, indent=2)

if __name__ == '__main__':
    main()