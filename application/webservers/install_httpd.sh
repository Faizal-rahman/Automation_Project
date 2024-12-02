#!/bin/bash
# Update and install Apache HTTP server
yum -y update
yum -y install httpd

# Fetch the private IP of the instance
myip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create the HTML file in the web server directory
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>${myip}</title>
</head>
<body>
  <h1>Group Members</h1>
  <ul>
    <li>Faizal Rahman Saffiudeen</li>
    <li>Reham Garaween</li>
    <li>Smriti Banjadee</li>
    <li>Esha Nikhil Chawda</li>
  </ul>
  <img src="https://s3.amazonaws.com/your-bucket-name/image.jpg" alt="Group Photo">
</body>
</html>
EOF

# Start and enable the Apache HTTP server
sudo systemctl start httpd
sudo systemctl enable httpd
