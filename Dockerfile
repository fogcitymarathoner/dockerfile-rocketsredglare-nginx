FROM richarvey/nginx-php-fpm:php5

# removed original raw IP site
RUN rm /etc/nginx/sites-available/default.conf
RUN rm /etc/nginx/sites-enabled/default.conf


#
# cake.rocketsredglare.com
#
ADD sites-available/cake.rocketsredglare.com /etc/nginx/sites-available/cake.rocketsredglare.com
RUN ln -s /etc/nginx/sites-available/cake.rocketsredglare.com /etc/nginx/sites-enabled/cake.rocketsredglare.com


#
# rocketsredglare.com
#
ADD sites-available/rocketsredglare.com /etc/nginx/sites-available/rocketsredglare.com
RUN ln -s /etc/nginx/sites-available/rocketsredglare.com /etc/nginx/sites-enabled/rocketsredglare.com

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

#
# s3.sfblur.com
#
ADD sites-available/s3.sfblur.com /etc/nginx/sites-available/s3.sfblur.com
RUN ln -s /etc/nginx/sites-available/s3.sfblur.com /etc/nginx/sites-enabled/s3.sfblur.com

RUN apk update
RUN apk add openssl
RUN apk add php5 wget xz alpine-sdk rsync python

# Witness pristine /usr/local file state
RUN find /usr/local > usr_local_pristine.txt

# install easy_install then pip
RUN wget https://bootstrap.pypa.io/ez_setup.py -O - > garb.py
RUN python garb.py

  
RUN pwd
# pip
RUN easy_install pip
 
