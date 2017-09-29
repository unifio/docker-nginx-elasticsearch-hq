FROM nginx:1.12.1-alpine

EXPOSE 80

ADD https://github.com/royrusso/elasticsearch-HQ/tarball/master /
RUN tar -xzf master && unlink master
RUN mv *elasticsearch-HQ-* /app

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ADD run.sh /
CMD ["sh", "/run.sh"]
