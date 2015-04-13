# docker-elasticsearch-hq

This is an example Docker image for elasticsearch-hq with AWS ELB compatible SSL enforcement and a basic user authentication

## Running:

```console
docker run --name elasticsearch-hq \
           -p 8080:80 \
           -e HOST=elasticsearch-hq.example.com \
           -e PASSWORD=correcthorsebatterystaple \
           -e PORT=80 \
           ianblenke/nginx-elasticsearch-hq
```

This can also be deployed PaaS via something that is 12-factor Dockerfile aware, like [Deis](http://deis.io).

