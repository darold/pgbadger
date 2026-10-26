# Based on https://github.com/matsuu/docker-pgbadger

FROM alpine
RUN \
  apk update && \
  apk upgrade && \
  apk add perl && \
  apk add --virtual .build curl make

ADD . /workdir
RUN \
  ( \
    cd /workdir && \
    perl Makefile.PL && \
    make install \
  ) && \
  apk del --purge .build && \
  rm -rf /workdir/*

WORKDIR /workdir
ENTRYPOINT ["/usr/local/bin/pgbadger"]
CMD ["--help"]
