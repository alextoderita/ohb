FROM node:6-alpine as builder
RUN apk -U upgrade \
 && apk add git

RUN git clone https://github.com/seejohnrun/haste-server.git /app
WORKDIR /app
RUN npm install

FROM node:6-alpine
LABEL maintainer="jesse@weisner.ca"
LABEL build_id="1567196314"

RUN apk upgrade --no-cache

COPY --from=builder /app /app
RUN chmod -R g+rw /app
ADD https://raw.githubusercontent.com/rlister/dockerfiles/master/hastebin/app.sh /app/
RUN chmod 755 /app/app.sh

COPY s.sh /s.sh
RUN chmod 755 /s.sh

WORKDIR /app
EXPOSE 7777
ENV STORAGE_TYPE file

CMD [ "./app.sh" ]
