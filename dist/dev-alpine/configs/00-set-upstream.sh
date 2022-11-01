#!/bin/sh

set -e

# Set upstream conf
echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/00_upstream.conf;

exit 0
