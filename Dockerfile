FROM alpine:latest

# Prepare
RUN apk add --update make perl
COPY . /tmp
WORKDIR /tmp

# Install
RUN perl Makefile.PL
RUN make && make install

# Clean up
RUN apk del make 
RUN rm -rf /var/cache/apk/*

ENTRYPOINT ["pgbadger"]
