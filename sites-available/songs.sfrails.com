upstream app1_server {
  server unix:/home/marc/rails_apps/songs/tmp/sockets/unicorn.sock fail_timeout=0;
}

server {
  listen 80;
  server_name songs.sfrails.com www.songs.sfrails.com;
  root /home/marc/rails_apps/songs/public;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @app1_server;
  location @app1_server {
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header Host $http_host;
  proxy_redirect off;
  proxy_pass http://app1_server;
 }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 4G;
  keepalive_timeout 10;
}
