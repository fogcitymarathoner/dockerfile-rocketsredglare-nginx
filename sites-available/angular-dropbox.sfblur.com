
    server {
       server_name www.angular-dropbox.sfblur.com;

       return 301 $scheme://angular-dropbox.sfblur.com$request_uri;
    }

    server {
        listen       80;
        # 
	root /var/www/html/angular-dropbox.sfblur.com;

        server_name  angular-dropbox.sfblur.com;

        access_log /dev/stdout;
        error_log /dev/stdout;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        location / {
                index  index.html index.htm;
        }
        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }
