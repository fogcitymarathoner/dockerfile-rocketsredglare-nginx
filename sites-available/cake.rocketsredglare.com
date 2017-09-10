    server {
       server_name www.cake.rocketsredglare.com;
       #rewrite ^(.*) http://www.cake.rocketsredglare.com$1 permanent;

       return 301 $scheme://cake.rocketsredglare.com$request_uri;
    }

    server {
        listen       80;

	root /var/www/html/cake.rocketsredglare.com;

        server_name  cake.rocketsredglare.com;

	access_log /var/log/nginx/default.access.log;
	error_log /var/log/nginx/default.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host

        location / {
                # force login to use https
                rewrite (.*) https://cake.rocketsredglare.com$1 permanent;
        }

    }

    # HTTPS server
    #
    server {
        listen       443;

	
	root /var/www/html/cake.rocketsredglare.com;
	index index.php index.html index.htm pmwiki.php;
        server_name  cake.rocketsredglare.com;

        ssl                  on;
        ssl_certificate      /openssl_keys/cake.rocketsredglare.com/ssl.crt;
		ssl_certificate_key  /openssl_keys/cake.rocketsredglare.com/server.key;
        ssl_session_timeout  5m;

        ssl_protocols  SSLv2 SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers   on;
        
        # that's for all other content on the web host

	location /pics {
		autoindex   off;
		index       index.php ;
	}
	# that's for cakephp

	location /personal {
		rewrite_log on;
		error_log /var/log/nginx/notice.log notice; # just for debuggin

		if (-f $request_filename) {
			break;
		}

		# Avoid recursivity
		if ($request_uri ~ /webroot/index.php) {
			break;
		}

		rewrite ^/personal$ /personal/ permanent;
		rewrite ^/personal/app/webroot/(.*) /personal/app/webroot/index.php?url=$1 last;
		rewrite ^/personal/(.*)$ /personal/app/webroot/$1 last;

	}
	location /rrg {
		rewrite_log on;
		error_log /var/log/nginx/notice.log notice; # just for debuggin

		if (-f $request_filename) {
			break;
		}

		# Avoid recursivity
		if ($request_uri ~ /webroot/index.php) {
			break;
		}

		rewrite ^/rrg$ /rrg/ permanent;
		rewrite ^/rrg/app/webroot/(.*) /rrg/app/webroot/index.php?url=$1 last;
		rewrite ^/rrg/(.*)$ /rrg/app/webroot/$1 last;
	}
	location /biz {
		rewrite_log on;
		error_log /var/log/nginx/notice.log notice; # just for debuggin

		if (-f $request_filename) {
			break;
		}

		# Avoid recursivity
		if ($request_uri ~ /webroot/index.php) {
			break;
		}

		rewrite ^/biz$ /biz/ permanent;
		rewrite ^/biz/app/webroot/(.*) /biz/app/webroot/index.php?url=$1 last;
		rewrite ^/biz/(.*)$ /biz/app/webroot/$1 last;
	}

        location /pics/static {
                autoindex on;
                alias /home/marc/python_apps/pics/media/;
        }

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

