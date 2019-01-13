server {
     listen 8080;
     location / {
         root ${ remote_static_file_path };
         autoindex off;
     }
}