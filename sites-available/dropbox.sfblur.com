
    upstream fup_app_dropbox {
         server 54.191.47.109:9101;
    }

    server {
       server_name www.dropbox.sfblur.com;

    return 301 $scheme://dropbox.sfblur.com$request_uri;
    }

    server {
        listen       80;
        # 
	root /var/www/html/dropbox/;

        server_name  dropbox.sfblur.com;

        access_log /dev/stdout;
        error_log /dev/stdout;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
           proxy_pass         http://fup_app_dropbox;
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
