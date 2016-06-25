FROM richarvey/nginx-php-fpm

# removed original raw IP site
RUN rm /etc/nginx/sites-available/default.conf
RUN rm /etc/nginx/sites-enabled/default.conf


#
# cake.rocketsredglare.com
#
# ADD sites-available/cake.rocketsredglare.com /etc/nginx/sites-available/cake.rocketsredglare.com
# RUN ln -s /etc/nginx/sites-available/cake.rocketsredglare.com /etc/nginx/sites-enabled/cake.rocketsredglare.com

#
# Default raw IP site
#
ADD conf/nginx-pmwiki-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

#
# sfgeek.net
#
ADD sites-available/sfgeek.net /etc/nginx/sites-available/sfgeek.net
RUN ln -s /etc/nginx/sites-available/sfgeek.net /etc/nginx/sites-enabled/sfgeek.net

#
# sfrails.com
#
ADD sites-available/sfrails.com /etc/nginx/sites-available/sfrails.com
RUN ln -s /etc/nginx/sites-available/sfrails.com /etc/nginx/sites-enabled/sfrails.com

