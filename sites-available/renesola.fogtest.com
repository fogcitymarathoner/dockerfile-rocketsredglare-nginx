
    upstream renesola_app {
         server 127.0.0.1:8102;
    }
    upstream renesola_production_app {
         server 127.0.0.1:8103;
    }
    server {
       server_name www.renesola.fogtest.com;
       #rewrite ^(.*) http://www.sfgeek.net$1 permanent;

    return 301 $scheme://renesola.fogtest.com$request_uri;
    }

    server {
        listen       80;

	root /home/marc/python_apps/renesola;

        server_name  renesola.fogtest.com;

        access_log /var/log/nginx/renesola.fogtest.log;
        error_log /var/log/nginx/renesola.fogtest.log;
       location /api {
          proxy_pass         http://renesola_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /renesola/static {
               autoindex on;
               alias /home/marc/python_test_apps/renesola/static/;
       }

       location /renesola {
          proxy_pass         http://renesola_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }


       location /static {
               autoindex on;
               alias /home/marc/python_test_apps/renesola-production/static/;
       }
        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host
	# https does not work with enlighted crm
	#
	location / {
  		#include uwsgi_params;
  		#uwsgi_pass localhost:8083;
                rewrite (.*) https://renesola.fogtest.com$1 permanent;
	}

        location /admin {
                # force login to use https
                rewrite (.*) https://renesola.fogtest.com$1 permanent;
        }

        location /auth/login {
                # force login to use https
                rewrite (.*) https://renesola.fogtest.com$1 permanent;
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


        root /home/marc/python_apps/renesola;

        server_name  renesola.fogtest.com;

        access_log /var/log/nginx/renesola.fogtest.access.log;
        error_log /var/log/nginx/renesola.fogtest.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host

       location /renesola/static {
               autoindex on;
               alias /home/marc/python_test_apps/renesola/static/;
       }
       location /api-auth {
          proxy_pass         http://renesola_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /api {
          proxy_pass         http://renesola_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /renesola {
          proxy_pass         http://renesola_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }


       location /static {
               autoindex on;
               alias /home/marc/python_test_apps/renesola-production/static/;
       }
       location / {
          proxy_pass         http://renesola_production_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }

        ssl                  on;
        ssl_certificate      /home/bitnami/certs/server.crt;
        ssl_certificate_key  /home/bitnami/certs/server.key;

        ssl_session_timeout  5m;

        ssl_protocols  SSLv2 SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers   on;

        # that's for all other content on the web host

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /opt/bitnami/nginx/html$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

