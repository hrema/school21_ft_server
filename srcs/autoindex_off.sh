#!/bin/bash

cp /var/www/hrema/autoindex/nginx_autoindex_off.conf /etc/nginx/sites-available/hrema
service nginx reload
echo "autoindex off"
