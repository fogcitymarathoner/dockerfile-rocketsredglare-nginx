
    server {
       server_name www.rocketsredglare.com;
       rewrite ^(.*) http://rocketsredglare.com$1 permanent;
    }

    server {
        listen       80;

	root /var/www/html/rocketsredglare.com;
	index index.php index.html index.htm pmwiki.php;

	access_log /var/log/nginx/default.access.log;
	error_log /var/log/nginx/default.error.log;

	server_name rocketsredglare.com;
	location / {
		try_files $uri $uri/ /index.html;
	}
		
	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php-fpm.sock;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param SCRIPT_NAME $fastcgi_script_name;
		fastcgi_index index.php;
		include fastcgi_params;
	}


}
