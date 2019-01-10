#!/bin/bash

apt-get update


apt-get install -y nginx
ufw allow 'Nginx HTTP'
systemctl restart nginx
rm /etc/nginx/sites-enabled/default
echo -e 'server {
     listen 8080;
     location / {
         root /home/ubuntu/;
         autoindex off;
     }
}' > /etc/nginx/sites-enabled/task9.ml.conf


systemctl restart nginx

aws s3 cp s3://s3-website-task9.ml/index.html /home/ubuntu/index.html

