#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Welcome from ${prefix}!</title>
</head>
<body style="font-family: Arial, sans-serif; text-align: center;">
  <h1 style="color: turquoise;">Welcome to Assignment 2, Group 4!</h1>
  <p>My private IP is: <strong>$myip</strong></p>
  <p>Prepared by:</p>
  <ul style="list-style-type: none; padding: 0;">
    <li>Faizal Rahman Saffiudeen</li>
    <li>Reham Garaween</li>
    <li>Smriti Banjade</li>
    <li>Esha Nikhil Chawda</li>
  </ul>
  <p>Environment: <strong>${env}</strong></p>
  <img src="https://group4seneca.s3.us-east-1.amazonaws.com/Bucketimg.jpeg" alt="Group Photo" style="max-width: 500px; margin-top: 20px;">
  <footer style="margin-top: 20px;">
    <p>Built by Terraform</p>
  </footer>
</body>
</html>
EOF
sudo systemctl start httpd
sudo systemctl enable httpd