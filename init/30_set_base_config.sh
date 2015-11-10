#!/bin/bash
mkdir -p /config/apache/site-confs /config/www /config/log/apache /config/keys

if [ ! -f "/config/apache/apache2.conf" ]; then
cp /defaults/apache2.conf /config/apache/apache2.conf
fi
cp config/apache/apache2.conf /etc/apache2/apache2.conf

if [ ! -f "/config/apache/ports.conf" ]; then
cp /defaults/ports.conf /config/apache/ports.conf
fi

if [ ! -f "/config/apache/site-confs/default.conf" ]; then
cp /defaults/default.conf /config/apache/site-confs/default.conf
fi

if [[ $(find /config/www -type f | wc -l) -eq 0 ]]; then
cp /defaults/index.html /config/www/index.html
fi

chown -R abc:abc /config
chown -R abc:abc /var/lib/apache2


