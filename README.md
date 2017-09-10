# dockerfile-rocketsredglare-nginx

Docker image for moving web server to ECS

Default server for raw IP testing doesn't work right unless '/' is at end of url
0.0.0.0/sfrails.com/

PHP-FPM cannot read Environment Variables exported to containers.

This is the only container of mine that runs PHP and has MySQL access.

## Changing sites
After this container is built and tagged as latest.  Sites are deployed in Dockerfile.

For MoinWiki docker start mc-wiki point browser at https://rocketsredglare.com:9100/


