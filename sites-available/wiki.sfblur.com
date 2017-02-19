
    upstream fup_app_wiki {
         server 54.191.47.109:9100;
    }

    server {
       server_name www.wiki.sfblur.com;

    return 301 $scheme://wiki.sfblur.com$request_uri;
    }

    server {
        listen       80;
        # 
	root /var/www/html/wiki/;

        server_name  wiki.sfblur.com;

        access_log /dev/stdout;
        error_log /dev/stdout;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
                # force login to use https
                rewrite (.*) https://wiki.sfblur.com$1 permanent;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }
    # HTTPS server
    #
    server {
        listen       443;

        root /var/www/html/wiki.com;
        index index.html;
        server_name  wiki.sfblur.com;

        ssl                  on;
        ssl_certificate      /etc/ssl/certs/cert.pem;
        ssl_certificate_key  /etc/ssl/private/key.pem
        ssl_session_timeout  5m;

        ssl_protocols  SSLv2 SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;

        location / {
           proxy_pass         http://fup_app_wiki;
           proxy_redirect     off;
           proxy_set_header   Host $host;
           proxy_set_header   X-Real-IP $remote_addr;
           proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header   X-Forwarded-Host $server_name;
        }
    }
