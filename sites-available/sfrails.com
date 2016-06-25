# You may add here your
# server {
#	...
# }
# statements for each of your virtual hosts to this file

##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
#
# Generally, you will want to move this file somewhere, and start with a clean
# file but keep this around for reference. Or just disable in sites-enabled.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##
server {
   server_name www.sfrails.com;
   return 301 $scheme://sfrails.com$request_uri;
}

server {
	listen   80; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default ipv6only=on; ## listen for ipv6

	root /var/www/html/sfrails.com;
	index index.php index.html index.htm pmwiki.php;

	# Make site accessible from http://sfrails.com/
	server_name sfrails.com;
	access_log /var/log/nginx/default.access.log;
	error_log /var/log/nginx/default.error.log;

	location / {
			# force login to use https
			rewrite (.*) https://sfgeek.net$1 permanent;
	}
}

# HTTPS server
#
server {
	listen 443;
	
	root /var/www/html/sfrails.com;
	index index.php index.html index.htm pmwiki.php;

	# Make site accessible from https://sfrails.com/
	server_name sfrails.com;
	

	ssl on;
    ssl_certificate      /openssl_keys/sfrails.com/ssl.crt;
    ssl_certificate_key  /openssl_keys/sfrails.com/server.key;

	ssl_session_timeout 5m;

	ssl_protocols SSLv3 TLSv1;
	ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
	ssl_prefer_server_ciphers on;

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


# another virtual host using mix of IP-, name-, and port-based configuration
#
#server {
#	listen 8000;
#	listen somename:8080;
#	server_name somename alias another.alias;
#	root html;
#	index index.html index.htm;
#
#	location / {
#		try_files $uri $uri/ /index.html;
#	}
#}

