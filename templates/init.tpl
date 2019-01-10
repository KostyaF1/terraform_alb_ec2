#!/bin/bash

apt-get update

apt-get install -y nginx
ufw allow 'Nginx HTTP'
systemctl restart nginx
rm ${ remote_conf_file_path_nginx }default
echo -e 'server {
     listen 8080;
     location / {
         root ${ remote_static_file_path };
         autoindex off;
     }
}' > ${ remote_conf_file_path_nginx }${ conf_file_name }

systemctl restart nginx


