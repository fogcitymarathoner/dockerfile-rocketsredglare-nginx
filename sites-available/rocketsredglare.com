
    server {
       server_name www.rocketsredglare.com;
       #rewrite ^(.*) http://www.rocketsredglare.com$1 permanent;

    return 301 $scheme://rocketsredglare.com$request_uri;
    }

    server {
        listen       80;

	root /var/www/html/rocketsredglare.com;
		index index.php index.html index.htm pmwiki.php;
			

		access_log /var/log/nginx/default.access.log;
		error_log /var/log/nginx/default.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host

        location / {
                # force login to use https
                rewrite (.*) https://rocketsredglare.com$1 permanent;
        }

    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    server {
        listen       443;
	root /var/www/html/rocketsredglare.com;
        server_name  rocketsredglare.com;

        ssl                  on;
        ssl_certificate      /openssl_keys/rocketsredglare.com/ssl.crt;
        ssl_certificate_key  /openssl_keys/rocketsredglare.com/server.key;

        ssl_session_timeout  5m;

        ssl_protocols  SSLv2 SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers   on;

        # that's for all other content on the web host

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

