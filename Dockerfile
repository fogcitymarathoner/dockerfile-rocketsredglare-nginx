FROM richarvey/nginx-php-fpm

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
# sfblur.com - First Non PHP Site
#
ADD sites-available/sfblur.com /etc/nginx/sites-available/sfblur.com
RUN ln -s /etc/nginx/sites-available/sfblur.com /etc/nginx/sites-enabled/sfblur.com

RUN apk update
# RUN apk add openssl-dev
RUN apk add openssl
RUN apk add php5 wget xz alpine-sdk rsync mysql-dev python-dev

# Witness pristine /usr/local file state
RUN find /usr/local > usr_local_pristine.txt
#
# Alpine is neither RPM or DEB
#
# Saving rails FPM gem support until there's a new home
#
# RUN apk add ruby ruby-dev ruby-irb ruby-rdoc ruby-ri libffi-dev
# RUN gem install rails fpm

#
# Python 2.7.11: alpine-python-2.7.11
#
RUN wget http://python.org/ftp/python/2.7.11/Python-2.7.11.tar.xz
RUN ls -la
RUN tar xf Python-2.7.11.tar.xz
WORKDIR Python-2.7.11
RUN ls
RUN ./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN make && make altinstall

# install easy_install then pip
RUN wget https://bootstrap.pypa.io/ez_setup.py -O - > garb.py
RUN python2.7 garb.py

  
RUN pwd
# pip
RUN /usr/local/bin/easy_install-2.7 pip
  
# install small base of modules to support code delivery - fabric, pythongit
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
