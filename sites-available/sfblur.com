
    server {
       server_name www.sfblur.com;
       #rewrite ^(.*) http://www.sfgeek.net$1 permanent;

    return 301 $scheme://sfblur.com$request_uri;
    }

    server {
        listen       80;

	root /home/marc/python_apps/djcms;

        server_name  sfblur.com;

        access_log /var/log/nginx/dj.access.log;
        error_log /var/log/nginx/dj.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host
location / {
  include uwsgi_params;
  uwsgi_pass localhost:8080;
}
        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}


        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
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
	root /home/marc/sfrails.net;
        server_name  sfblur.com;

        ssl                  on;
        ssl_certificate      /home/bitnami/certs/server.crt;
        ssl_certificate_key  /home/bitnami/certs/server.key;

        ssl_session_timeout  5m;

        ssl_protocols  SSLv2 SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers   on;

        # that's for all other content on the web host
		location / {
			autoindex   off;
			index       pmwiki.php index.php index.html index.htm;
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
		location ~ \.php$ {
				fastcgi_split_path_info ^(.+\.php)(/.+)$;
				# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
				fastcgi_pass   127.0.0.1:9000;
				# Edit listen directive in /etc/php5/fpm/pool.d/www.conf 
				fastcgi_index index.php;
				include fastcgi_params;
		}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /opt/bitnami/nginx/html$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

