#!/bin/bash

cp /var/www/hrema/autoindex/nginx.conf /etc/nginx/sites-available/hrema
service nginx restart
echo "autoindex on"
