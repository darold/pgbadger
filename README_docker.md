# Dockerfile
## Build docker image
```
$ docker build -t pgbadger:latest .
```

To be able to rebuild existing image when source code changes, run
```
$ docker rmi pgbadger
```
and then rebuild the image


## Use
```
$ docker run -i --rm  -v $(pwd):/workdir pgbadger:latest -f stderr  -p "%t:%r:%u@%d:[%p]:" postgresql.log.2019-11-08-10 --outfile report.html
```

Or parse multiple files at once with 4 threads:
```
$ cat files_to_parse.txt
postgresql.log.2019-11-08-08
postgresql.log.2019-11-08-09
postgresql.log.2019-11-08-10
postgresql.log.2019-11-08-11

$ docker run -i --rm  -v $(pwd):/workdir pgbadger:latest -j 4 -f stderr  -p "%t:%r:%u@%d:[%p]:" -L files_to_parse.txt --outfile report.html
```
