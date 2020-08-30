FROM debian:buster

WORKDIR /

#UPDATE
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y vim

#LEMP
RUN apt-get install -y nginx
RUN apt-get install -y mariadb-server
RUN apt-get install -y php php-fpm php-mysql

# Config Access
RUN chown -R www-data:www-data /var/www/
RUN chmod -R 755 /var/www/*

#CONFIGURING NGINX TO USE THE PHP
RUN mkdir /var/www/hrema
RUN chown -R $USER:$USER /var/www/hrema
COPY ./srcs/nginx.conf /etc/nginx/sites-available/hrema
COPY ./srcs/index.nginx-debian.html var/www/hrema/
RUN ln -s /etc/nginx/sites-available/hrema /etc/nginx/sites-enabled
RUN rm -rf /etc/nginx/sites-enabled/default

RUN apt-get install -y wget

#PHPMYADMIN
RUN apt-get install -y php-mbstring php-zip php-gd php-xml php-pear php-gettext php-cgi
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
RUN tar -xzvf phpMyAdmin-5.0.2-english.tar.gz
RUN mv ./phpMyAdmin-5.0.2-english /var/www/hrema/phpmyadmin
COPY ./srcs/config.inc.php /var/www/hrema/phpmyadmin/config.inc.php
#RUN chmod 664 /var/www/hrema/phpmyadmin/config.inc.php
#RUN chown -R www-data:www-data /var/www/hrema/phpmyadmin

#SSL
RUN apt-get install -y openssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-subj "/C=ru/ST=Moscow/L=Moscow/O=no/OU=no/CN=hrema" \ 
	-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	

#WORDPRESS
RUN apt-get install -y php-curl php-intl php-soap php-xmlrpc
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzvf latest.tar.gz
RUN mv wordpress/ /var/www/hrema/wordpress
COPY ./srcs/wp-config.php /var/www/hrema/wordpress/wp-config.php
#RUN chown -R www-data:www-data /var/www/hrema/wordpress
#RUN chmod 664 /var/www/hrema/wordpress/wp-config.php

#MYSQL
RUN service mysql start && mysql -u root \
	mysql --execute="CREATE USER 'name'@'localhost' IDENTIFIED BY 'pass'; \
					GRANT ALL PRIVILEGES ON * . * TO 'name'@'localhost'; \
					FLUSH PRIVILEGES; \
					CREATE DATABASE wordpress; \
					GRANT ALL ON wordpress. * TO 'name'@'localhost' IDENTIFIED BY 'pass'; \
					FLUSH PRIVILEGES;"


COPY ./srcs/start.sh .

COPY ./srcs/autoindex_on.sh .
COPY ./srcs/autoindex_off.sh .
RUN mkdir /var/www/hrema/autoindex
COPY ./srcs/nginx_autoindex_off.conf /var/www/hrema/autoindex
COPY ./srcs/nginx.conf /var/www/hrema/autoindex

EXPOSE 80 443

CMD bash start.sh
