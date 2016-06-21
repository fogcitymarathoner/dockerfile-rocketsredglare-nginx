    upstream coconuts_app {
         server 127.0.0.1:8092;
    }
    upstream radio_app {
         server 127.0.0.1:8093;
    }
    upstream radio_app_test {
         server 127.0.0.1:8094;
    }
    upstream vidality_crunchbase_service {
         server 127.0.0.1:8095;
    }
    upstream enlighted_cherrypy_customers {
         server 127.0.0.1:8098;
    }

    upstream fogtest_fix_app_test{
	server 127.0.0.1:8099;
    }
    upstream vidality_linkedin_service {
         server 127.0.0.1:8100;
    }

    upstream chowpad_app {
         server 127.0.0.1:8101;
    }
    # django app bird
    upstream tpages_personal {
         server 127.0.0.1:8111;
    }

    server {
       server_name www.fogtest.com;
       #rewrite ^(.*) http://www.sfgeek.net$1 permanent;

    return 301 $scheme://fogtest.com$request_uri;
    }

    server {
        listen       80;

	root /home/marc/python_apps/fogtest/www;

        server_name  fogtest.com;

        access_log /var/log/nginx/fogtest.log;
        error_log /var/log/nginx/fogtest.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host
	# https does not work with enlighted crm
	#
	location /rabbitmq/api/queues/ {
	   proxy_pass         http://0.0.0.0:55672/api/queues/%2F/;
	   proxy_redirect     off;
	   proxy_set_header   Host $host;
	   proxy_set_header   X-Real-IP $remote_addr;
	   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_set_header   X-Forwarded-Host $server_name;
	}
	location /rabbitmq/api/exchanges/ {
	   proxy_pass         http://0.0.0.0:55672/api/exchanges/%2F/;
	   proxy_redirect     off;
	   proxy_set_header   Host $host;
	   proxy_set_header   X-Real-IP $remote_addr;
	   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_set_header   X-Forwarded-Host $server_name;
	}
	location /rabbitmq/ {
	   proxy_pass         http://0.0.0.0:55672/;
	   proxy_redirect     off;
	   proxy_set_header   Host $host;
	   proxy_set_header   X-Real-IP $remote_addr;
	   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_set_header   X-Forwarded-Host $server_name;
	}
	location /customers_test {
	   proxy_pass         http://enlighted_cherrypy_customers;
	   proxy_redirect     off;
	   proxy_set_header   Host $host;
	   proxy_set_header   X-Real-IP $remote_addr;
	   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_set_header   X-Forwarded-Host $server_name;
	}
        location /crm_test/static {
                autoindex on;
                alias /home/marc/python_test_apps/rma/static/;
	}
        location /crm_test {
                include uwsgi_params;
                uwsgi_pass localhost:8097;
        }
        location /static {
                autoindex on;
                alias /home/marc/python_apps/fogtest/www/media/;
                #rewrite (.*) https://fogtest.com$1 permanent;
        }
        location /radio_test/static {
                autoindex on;
                alias /home/marc/python_test_apps/fogtest_radio_test/static/;
        }
        location /radio_test {
           proxy_pass         http://radio_app_test;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
        }
        location /tpages {
           proxy_pass         http://tpages_personal;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
        }
	location / {
  		#include uwsgi_params;
  		#uwsgi_pass localhost:8083;
                rewrite (.*) https://fogtest.com$1 permanent;
	}

        location /admin {
                # force login to use https
                rewrite (.*) https://fogtest.com$1 permanent;
        }

        location /auth/login {
                # force login to use https
                rewrite (.*) https://fogtest.com$1 permanent;
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


        root /home/marc/python_apps/fogtest/www;

        server_name  fogtest.com;

        access_log /var/log/nginx/fogtest.access.log;
        error_log /var/log/nginx/fogtest.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host

        location /rrg {
                alias /home/marc/php_test_apps/rrg;
                autoindex   off;
                index       index.php index.html index.htm;
                rewrite_log on;
                error_log /var/log/nginx/notice.log notice; # just for debuggin

                if (-f $request_filename) {
                        break;
                }

                # Avoid recursivity
                if ($request_uri ~ /webroot/index.php) {
                        break;
                }

                rewrite ^/app/webroot/(.*) /app/webroot/index.php?url=$1 last;
                rewrite ^/(.*)$ /app/webroot/$1 last;

        }
        location /static {
                autoindex on;
                alias /home/marc/python_apps/fogtest/www/media/;
        }
        location /radio_test/fullScreenMusic {
                autoindex on;
                alias /home/marc/python_test_apps/fogtest_radio_test/fullScreenMusic/;
        }

        location /radio_test/play/static {
                autoindex on;
                alias /home/marc/python_test_apps/fogtest_radio_test/static/;
        }
        location /radio_test/static {
                autoindex on;
                alias /home/marc/python_test_apps/fogtest_radio_test/static/;
        }
        location /crunchbase_search/static {
                autoindex on;
                alias /home/marc/python_test_apps/crunchbase/static/;
        }
       location /crunchbase_search {
          proxy_pass         http://vidality_crunchbase_service;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /vidalitylinkedinservice {
          proxy_pass         http://vidality_linkedin_service;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /radio_test {
          proxy_pass         http://radio_app_test;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /fix {
          proxy_pass         http://fogtest_fix_app_test;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
       location /fix/static {
               autoindex on;
               alias /home/marc/python_test_apps/fogtest/www2/static/;
       }
       location /coconuts {
          proxy_pass         http://coconuts_app;
          proxy_redirect     off;
          proxy_set_header   Host $host;
          proxy_set_header   X-Real-IP $remote_addr;
          proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Host $server_name;
       }
        location /radio/fullScreenMusic {
                autoindex on;
                alias /home/marc/python_apps/fogtest_radio/fullScreenMusic/;
        }
        location /radio/play/static {
                autoindex on;
                alias /home/marc/python_apps/fogtest_radio/static/;
        }
        location /radio/static {
                autoindex on;
                alias /home/marc/python_apps/fogtest_radio/static/;
	}
	location /radio {
	   proxy_pass         http://radio_app;
	   proxy_redirect     off;
	   proxy_set_header   Host $host;
	   proxy_set_header   X-Real-IP $remote_addr;
	   proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_set_header   X-Forwarded-Host $server_name;
	}


        location /chowpad/static {
                autoindex on;
                alias /home/marc/python_test_apps/chowpad/static/;
	}
        location /chowpad {
           proxy_pass         http://chowpad_app;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
        }




        location /tpages {
           proxy_pass         http://tpages_personal;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
        }
        location / {
                include uwsgi_params;
                uwsgi_pass localhost:8083;
        }

        ssl                  on;
        ssl_certificate      /home/marc/openssl_keys/fogtest.com/ssl.crt;
        ssl_certificate_key  /home/marc/openssl_keys/fogtest.com/server.key;

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

