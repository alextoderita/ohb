# OHB Container

## Getting Started

These instructions will cover deployment on Local and on Red Hat OpenShift Service on AWS (ROSA) for the docker container

### Prerequisities for Local Deployments

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Build and run the container locally

Build the httpd docker image:

```shell
$ docker build . --tag ohb:latest
[+] Building 2.4s (20/20) FINISHED                                                                                          docker:desktop-linux
 => [internal] load .dockerignore                                                                                                           0.0s
 => => transferring context: 2B                                                                                                             0.0s
 => [internal] load build definition from Dockerfile                                                                                        0.0s
 => => transferring dockerfile: 677B                                                                                                        0.0s
 => [internal] load metadata for docker.io/library/node:6-alpine                                                                            1.6s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                 0.0s
 => [builder 1/5] FROM docker.io/library/node:6-alpine@sha256:17258206fc9256633c7100006b1cfdf25b129b6a40b8e5d37c175026482c84e3              0.0s
 => [internal] load build context                                                                                                           0.0s
 => => transferring context: 62B                                                                                                            0.0s
 => https://raw.githubusercontent.com/rlister/dockerfiles/master/hastebin/app.sh                                                            0.6s
 => CACHED [stage-1 2/9] RUN apk upgrade --no-cache                                                                                         0.0s
 => CACHED [builder 2/5] RUN apk -U upgrade  && apk add git                                                                                 0.0s
 => CACHED [builder 3/5] RUN git clone https://github.com/seejohnrun/haste-server.git /app                                                  0.0s
 => CACHED [builder 4/5] WORKDIR /app                                                                                                       0.0s
 => CACHED [builder 5/5] RUN npm install                                                                                                    0.0s
 => CACHED [stage-1 3/9] COPY --from=builder /app /app                                                                                      0.0s
 => CACHED [stage-1 4/9] RUN chmod -R g+rw /app                                                                                             0.0s
 => CACHED [stage-1 5/9] ADD https://raw.githubusercontent.com/rlister/dockerfiles/master/hastebin/app.sh /app/                             0.0s
 => CACHED [stage-1 6/9] RUN chmod 755 /app/app.sh                                                                                          0.0s
 => CACHED [stage-1 7/9] COPY s.sh /s.sh                                                                                                    0.0s
 => CACHED [stage-1 8/9] RUN chmod 755 /s.sh &&     ./s.sh &&     chmod 644 /app/static/h.html                                              0.0s
 => CACHED [stage-1 9/9] WORKDIR /app                                                                                                       0.0s
 => exporting to image                                                                                                                      0.0s
 => => exporting layers                                                                                                                     0.0s
 => => writing image sha256:913cf27272f4ee1a5d07e97da50e9b43783daf5a5d414a8fcb9c4f93ba89c4e3                                                0.0s
 => => naming to docker.io/library/ohb:latest                                                                                                         0.0s
```

Start the ohb container locally:

```shell
$ docker run -dit --name ohb -p 7777:7777 ohb:latest
ce835f914a5660f8acaa1cf2993189e92f2859f5a384e9f394df11e537d29eff
```

Check the response of the container running locally:
```shell
$ curl -v http://localhost:7777/h.html
*   Trying 127.0.0.1:7777...
* Connected to localhost (127.0.0.1) port 7777 (#0)
> GET /h.html HTTP/1.1
> Host: localhost:7777
> User-Agent: curl/8.1.2
> Accept: */*
> 
< HTTP/1.1 200 OK
< cache-control: public, max-age=600
< last-modified: Sat, 09 Dec 2023 19:57:13 GMT
< etag: "144-277601-1702151833964"
< content-type: text/html
< content-length: 20
< Date: Sun, 10 Dec 2023 08:25:35 GMT
< Connection: keep-alive
< 
testing!
24.4M   /app
* Connection #0 to host localhost left intact
```

### Prerequisites for Cloud deployments - we're using Red Hat OpenShift Service on AWS (ROSA) in this example

* [OpenShift](https://docs.aws.amazon.com/ROSA/latest/userguide/getting-started.html)
* [OpenShift CLI](https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html)

#### Publish the docker image and run the application in OpenShift

Tag the docker image to be published to an external docker registry:
```shell
$ docker tag ohb:latest default-route-openshift-image-registry.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com/default/ohb:latest
```

Login to the external docker registry:
```shell
$ docker login -u <username> -p $(oc whoami -t) default-route-openshift-image-registry.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com
Login Succeeded
```

Push the previously tagged image to an external docker registry:
```shell
$ docker push default-route-openshift-image-registry.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com/default/ohb:latest
The push refers to repository [default-route-openshift-image-registry.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com/default/ohb]
99a043a1c1af: Pushed 
b9bf93af811f: Pushed 
28f18e7dc61c: Pushed 
27496babc700: Pushed 
fad7e2250d8f: Pushed 
92770f546e06: Pushed 
latest: digest: sha256:18236a491ffadb9e7ae3fdfc68cc0131148fa5f9004bc059c844a432106b3b72 size: 1573
```

Deploy a new OpenShift app called ohb:
```shell
$ oc new-app httpd --name=ohb
--> Found image d4c8d52 (4 minutes old) in image stream "default/httpd" under tag "latest" for "httpd"
--> Creating resources ...
    deployment.apps "httpd" created
    service "httpd" created
--> Success
```

Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
```shell
$ oc expose service/ohb
route.route.openshift.io/ohb exposed
```

Identify the route/FQDN port number for the exposed application:
```shell
$ oc get route ohb
NAME   HOST/PORT                                                         PATH   SERVICES   PORT       TERMINATION   WILDCARD
ohb    ohb-default.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com          ohb        7777-tcp                 None
```

Check the response of the publicly exposed app:

```shell
$ curl -v http://ohb-default.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com/h.html
*   Trying 54.73.18.112:80...
* Connected to ohb-default.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com (54.73.18.112) port 80 (#0)
> GET /h.html HTTP/1.1
> Host: ohb-default.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com
> User-Agent: curl/8.1.2
> Accept: */*
> 
< HTTP/1.1 200 OK
< cache-control: public, max-age=600
< last-modified: Sat, 09 Dec 2023 19:57:13 GMT
< etag: "3145866-106956695-1702151833000"
< content-type: text/html
< content-length: 20
< date: Sun, 10 Dec 2023 08:33:04 GMT
< set-cookie: f0548a20ce1d32cfeb1220620a81acb5=daf3e0e77ea9bf5a6d8509dbb33ab6c0; path=/; HttpOnly
< cache-control: private
< 
testing!
24.4M   /app
* Connection #0 to host ohb-default.apps.rosa.rosa-hcp-public.gbk1.p3.openshiftapps.com left intact
```
