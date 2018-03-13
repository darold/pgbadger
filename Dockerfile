FROM alpine:latest

# Since Alpine linux 3.3 we can install on-the-fly
RUN apk add --no-cache bzip2 gzip openssh-client perl unzip xz

COPY pgbadger /usr/local/bin

ENTRYPOINT ["pgbadger"]
