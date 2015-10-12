FROM nginx:1.9

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# https://github.com/royrusso/elasticsearch-HQ/archive/master.tar.gz
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y git && \
    git clone https://github.com/royrusso/elasticsearch-HQ /app

ADD run.sh /
RUN chmod ugo+rx /run.sh

EXPOSE 80

CMD ["/run.sh"]
