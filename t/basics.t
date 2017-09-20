#!/usr/bin/env bats
# -*- shell-script -*-

@test "Inline help" {
    ./pgbadger --help
}

@test "Light log report to stdout" {
    ./pgbadger -o - t/fixtures/light.postgres.log.bz2
}

@test "Light log report to HTML" {
    ./pgbadger --outdir $BATS_TMPDIR t/fixtures/light.postgres.log.bz2
    # Assert out.html is not created in PWD.
    ! test -f out.html
}
