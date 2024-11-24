#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>welcome to assignment 2 group 4 ${prefix}! My private IP is $myip <font color="turquoise">  prepared by Smriti Banjade , Faizal Rahman Saffiudeen , Reham Garaween and Esha Nikhil Chawda in ${env} environment</font></h1><br>Built by Terraform! prepared by Smriti Banjade , Faizal Rahman Saffiudeen , Reham Garaween and Esha Nikhil Chawda"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd