server {
	listen 80;
	listen [::]:80;
	server_name stg-www.example.com;
	root /var/www/stg-www.example.com;
	index index.php index.html index.htm;
	location ~ /\. {
	  deny all;
	}
	location ~* /(?:uploads|files)/.*\.php$ {
	  deny all;
	}
	location / {
	  try_files $uri $uri/ @wordpress;
	}
	location /wp-json/ {
	  rewrite ^/wp-json/(.*?)$ /?rest_route=/$1 last;
	}
	location ~ \.php$ {
	  try_files $uri @wordpress;
	  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	  fastcgi_pass unix:/run/php/php7.2-fpm.sock;
	  include /etc/nginx/fastcgi_params;
	}
	location @wordpress {
	  fastcgi_param SCRIPT_FILENAME $document_root/index.php;
	  fastcgi_pass unix:/run/php/php7.2-fpm.sock;
	  include /etc/nginx/fastcgi_params;
	}
}
