#!/bin/bash
set -e

SCHEME=${SCHEME:-http}
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

if [ "${SCHEME}" == "https" ]; then
cat <<EOF >> $CONFDIR/default.conf
  # Enforce SSL
  if (\$http_x_forwarded_proto != '$SCHEME') {
    rewrite ^ $SCHEME://\$host$request_uri? permanent;
  }
EOF
fi

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
    if (\$request_method = OPTIONS ) {
      add_header Access-Control-Allow-Origin "$SCHEME://$HOST";
      add_header Access-Control-Allow-Methods "GET, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization";
      add_header Access-Control-Allow-Credentials "true";
      add_header Content-Length 0;
      add_header Content-Type text/plain;
      return 200;
    }
    proxy_pass http://elasticsearch/;
    expires max;
    access_log on;
  }

  location / {
    rewrite ^/$ index.html?url=$SCHEME://\$http_host/elastic-search-proxy redirect;
    root /app;
    if (\$request_method = OPTIONS ) {
      add_header Access-Control-Allow-Origin "$SCHEME://$HOST";
      add_header Access-Control-Allow-Methods "GET, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization";
      add_header Access-Control-Allow-Credentials "true";
      add_header Content-Length 0;
      add_header Content-Type text/plain;
      return 200;
    }
    index index.html;
#    try_files \$uri \$uri/;
    expires max;
    access_log on;
  }
}
EOF

echo Starting nginx
exec nginx -g "daemon off;"

