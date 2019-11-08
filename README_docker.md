# Dockerfile
## Build docker image
```
docker build -t pgbadger:latest .
```

To be able to rebuild existing image when source code changes, run
```
docker rmi pgbadger
```
and then rebuild the image


## Use
```
docker run -i --rm  -v $(pwd):/workdir pgbadger:latest -f stderr  -p "%t:%r:%u@%d:[%p]:" /workdir/postgresql.log.2019-11-08-10 --outfile /workdir/report.html
```
