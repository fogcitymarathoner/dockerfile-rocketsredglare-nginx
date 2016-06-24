FROM richarvey/nginx-php-fpm

# removed original raw IP site
RUN rm /etc/nginx/sites-available/default.conf
RUN rm /etc/nginx/sites-enabled/default.conf
# Default raw IP site
ADD conf/nginx-pmwiki-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
# sfrails.com
ADD sites-available/sfrails.com /etc/nginx/sites-available/sfrails.com
RUN ln -s /etc/nginx/sites-available/sfrails.com /etc/nginx/sites-enabled/sfrails.com
