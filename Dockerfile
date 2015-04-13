# Based on: https://github.com/nginxinc/docker-nginx/blob/master/Dockerfile, the genesis of the "nginx" docker image
FROM debian:wheezy
MAINTAINER Ian Blenke <ian@blenke.com>

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -Ls http://nginx.org/packages/keys/nginx_signing.key | apt-key add - && \
    echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y nginx && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/conf.d/default.conf && \
    rm /etc/nginx/conf.d/example_ssl.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y git && \
    git clone https://github.com/royrusso/elasticsearch-HQ /app

ADD run.sh /
RUN chmod ugo+rx /run.sh

VOLUME ["/app"]
VOLUME ["/var/cache/nginx"]

EXPOSE 80

CMD ["/run.sh"]
