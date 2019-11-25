#!/bin/bash
sudo yum install -y httpd
sleep 30
sudo service httpd start
sleep 10
sudo chkconfig httpd on
sudo chmod 777 -R /var/www/html/
echo 'This is my webpage - modified' > /var/www/html/index.html
