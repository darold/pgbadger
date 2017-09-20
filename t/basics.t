#!/usr/bin/env bats
# -*- shell-script -*-

@test "Inline help" {
    ./pgbadger --help
}

@test "Light log report to stdout" {
    ./pgbadger -o - t/fixtures/light.postgres.log.bz2
}

@test "Light log report to HTML" {
    rm -f out.html
    ./pgbadger --outdir $BATS_TMPDIR t/fixtures/light.postgres.log.bz2
    # Assert out.html is not created in PWD.
    ! test -f out.html
}

@test "From binary to JSON" {
    ./pgbadger --outdir $BATS_TMPDIR -o test-out.json \
               --format binary t/fixtures/light.postgres.bin
    test -f $BATS_TMPDIR/test-out.json
    SELECT=$(jq .database_info.postgres.SELECT < $BATS_TMPDIR/test-out.json)
    test $SELECT -gt 0
}
