#!/bin/bash
[[ ! -d "/config/www/serviio/git" ]] && (git clone https://github.com/SwoopX/Web-UI-for-Serviio.git /config/www/serviio && cd /config/www/serviio && git checkout Serviio-1.5)

chown -R abc:abc /config/www/serviio
