# docker-elasticsearch-hq

This is an example Docker image for elasticsearch-hq with AWS ELB compatible SSL enforcement and a basic user authentication

## Running:

```console
docker run --name elasticsearch-hq \
           -p 8080:80 \
           -e HOST=elasticsearch-hq.example.com \
           -e PASSWORD=correcthorsebatterystaple \
           -e SCHEME=http \
           -e PORT=80 \
           ianblenke/nginx-elasticsearch-hq
```

This can also be deployed PaaS via something that is 12-factor Dockerfile aware, like [Deis](http://deis.io).

After deploying, you can access it via the URL you exposed for it (after delegating DNS to it, of course).

When it asks for something to connect to, you can point it at the same web server URL root. Alternatively, you can embed it in the URL as a url= option:

http://elasticsearch-hq.example.com:8080/index.html?url=http://elasticsearch-hq.example.com:8080#

This is from the perspective of the web browser, and is what it will use to talk to the elasticsearch server.

The default SCHEME is HTTPS. You probably should use HTTPS urls as only basic auth is used, but there is nothing here requiring you to do that.
This really should use digest auth anyway.
