
    upstream fup_app {
         server 127.0.0.1:9191;
    }

    server {
       server_name www.sfblur.com;

    return 301 $scheme://sfblur.com$request_uri;
    }

    server {
        listen       80;

	root /var/www/html/rocketsredglare.com;

        server_name  sfblur.com;

        access_log /var/log/nginx/sfblur.com.access.log;
        error_log /var/log/nginx/sfblur.com.error.log;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
           proxy_pass         http://fup_app;
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

    }
