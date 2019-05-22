# How to contribute

## Before Submitting an issue

1. Upgrade to the latest version of pgBadger and see if the problem remains

2. Look at the [closed issues](https://github.com/darold/pgbadger/issues?state=closed), we may have already answered a similar problem

3. [Read the doc](http://pgbadger.darold.net/documentation.html). It is short and useful.


## Coding style

pgBadger project provides a [.editorconfig](http://editorconfig.org/) file to
setup consistent spacing in files. Please follow it!


## Keep Documentation Updated

The first pgBadger documentation is `pgbadger --help`. `--help` fills the
SYNOPSIS section in `doc/pgBadger.pod`. The DESCRIPTION section *must* be
written directly in `doc/pgBadger.pod`. `README` is the text formatting of
`doc/pgBadger.pod`. Update `README` and `doc/pgBadger.pod` with `make README`
and commit changes when contributing.

