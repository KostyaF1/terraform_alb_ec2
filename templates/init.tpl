#!/bin/bash

apt-get update


apt-get install -y nginx
ufw allow 'Nginx HTTP'
systemctl restart nginx
rm ${ remote_conf_file_path_nginx }default
echo -e 'server {
     listen 8080;
     location / {
         root /home/ubuntu/;
         autoindex off;
     }
}' > ${ remote_conf_file_path_nginx }${ conf_file_name }


systemctl restart nginx

aws s3 cp s3://${ bucket_name }/${ static_file_name } ${ remote_static_file_path }${ static_file_name }

