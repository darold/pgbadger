# How to contribute

## Before submitting an issue

1. Upgrade to the latest version of pgBadger and see if the problem remains

2. Look at the [closed issues](https://github.com/darold/pgbadger/issues?state=closed), we may have already answered a similar problem

3. [Read the doc](http://pgbadger.darold.net/documentation.html), it is short and useful

## Coding style

The pgBadger project provides a [.editorconfig](http://editorconfig.org/) file to
setup consistent spacing in files. Please follow it!

## Keep documentation updated

The first pgBadger documentation is `pgbadger --help`. `--help` fills the
SYNOPSIS section in `doc/pgBadger.pod`. The DESCRIPTION section *must* be
written directly in `doc/pgBadger.pod`. `README` is the text formatting of
`doc/pgBadger.pod`. 

After updating `doc/pdBadger.pod`, rebuild `README` and `README.md` with the following commands:
```shell
$ perl Makefile.PL && make README
```
When you're done contributing to the docs, commit your changes.  Note that you must have `pod2markdown` installed to generate `README.md`.
