
    upstream heroku_app {
         server 127.0.0.1:5000;
    }

    server {
       server_name www.test5000.fogtest.com;
       #rewrite ^(.*) http://www.fogtest.com$1 permanent;

    return 301 $scheme://test5000.fogtest.com$request_uri;
    }

    server {
        listen       80;

	root /home/marc/python_apps/jqfogtest;

        server_name  test5000.fogtest.com;

        access_log /var/log/nginx/test5000.access.log;
        error_log /var/log/nginx/test5000.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host
        location /static {
                autoindex on;
                alias /var/www/test5000.fogtest.com.static;
        }

        location / {
           proxy_pass         http://heroku_app;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
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


        root /home/marc/python_apps/jqfogtest;

        server_name  test5000.fogtest.com;

        access_log /var/log/nginx/test5000.access.log;
        error_log /var/log/nginx/test5000.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        # that's for all other content on the web host
        location /static {
                autoindex on;
                alias /var/www/test5000.fogtest.com.static;
        }
        # that's for all other content on the web host
        location / {
           proxy_pass         http://heroku_app;
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

