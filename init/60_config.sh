#!/bin/bash
mkdir -p /config/serviio/config /config/serviio/library

[[ -f /config/www/serviio/.htaccess ]] && rm /config/www/serviio/.htaccess

[[ ! -d /config/serviio/plugins ]] && cp -pr /app/serviio/plugins_orig /config/serviio/plugins

[[ -L /app/serviio/plugins && ! /app/serviio/plugins -ef /config/serviio/plugins ]] && unlink /app/serviio/plugins

[[ ! -L /app/serviio/plugins ]] && ln -s /config/serviio/plugins /app/serviio/plugins

[[ ! -f /config/serviio/config/application-profiles.xml || ! -f /config/serviio/config/log4j.xml || ! -f /config/serviio/config/profiles.xml ]] && cp /app/serviio/config/* /config/serviio/config/

chown -R abc:abc /app /config
