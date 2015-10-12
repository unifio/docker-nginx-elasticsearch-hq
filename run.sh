#!/bin/bash
set -e

USERNAME=${USERNAME:-elasticsearch-hq}
ES_PORT=${ES_PORT:-9200}
ES_HOST=${ES_HOST:-elasticsearch}
PORT=${PORT:-80}


CONFDIR=/etc/nginx/conf
[ -d /etc/nginx/conf.d ] && CONFDIR=/etc/nginx/conf.d

unlink $CONFDIR/default.conf

cat <<EOF > $CONFDIR/default.conf
upstream elasticsearch {
  server $ES_HOST:$ES_PORT;
  keepalive 15;
}
server {
  listen                *:$PORT ;
  server_name           _ default;
  access_log            /dev/stdout;
  error_log             /dev/stderr;
EOF

if [ "$PASSWORD" != "" ]; then

echo "$USERNAME:$(openssl passwd -crypt $PASSWORD)" > /passwords
cat <<EOF >> $CONFDIR/default.conf
  auth_basic "Protected Kibana";
  auth_basic_user_file /passwords;
EOF

fi

cat <<EOF >> $CONFDIR/default.conf
  proxy_read_timeout 90;
  proxy_http_version 1.1;
  proxy_set_header Connection "Keep-Alive";
  proxy_set_header Proxy-Connection "Keep-Alive";

  proxy_set_header X-Real-IP \$proxy_add_x_forwarded_for;
  proxy_set_header X-ELB-IP \$remote_addr;
  proxy_set_header X-ELB-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header Host \$http_host;
  proxy_set_header Referer \$http_referer;

  # For CORS Ajax
  proxy_pass_header Access-Control-Allow-Origin;
  proxy_pass_header Access-Control-Allow-Methods;
  proxy_hide_header Access-Control-Allow-Headers;
  add_header Access-Control-Allow-Headers 'X-Requested-With, Content-Type';
  add_header Access-Control-Allow-Credentials true;

  location /elastic-search-proxy {
    proxy_pass http://elasticsearch/;
    expires max;
    access_log on;
  }

  location / {
    rewrite ^/$ index.html?url=//\$http_host/elastic-search-proxy redirect;
    root /app;
    index index.html;
    expires max;
    access_log on;
  }
}
EOF

echo Starting nginx
exec nginx -g "daemon off;"

