#!/usr/bin/env bats
# -*- shell-script -*-

setup() {
    IN=t/fixtures/light.postgres.log.bz2
    BIN=$BATS_TMPDIR/out.bin
    OUT=$BATS_TMPDIR/out.json
    OUT_FROM_BIN=$BATS_TMPDIR/out_from_bin.json
    # Generate report from plain-text log
    ./pgbadger $IN -o $OUT
    # Generate intermediate binary file
    ./pgbadger $IN  -o $BIN
    # Generate report from binary file
    ./pgbadger $BIN --format=binary -o $OUT_FROM_BIN
}

#
# Assert that analyzing from a plain-text log and from the intermediate binary file
# will provide the exact same results
#

@test "Consistent count" {
    N=$(jq .database_info.postgres.count < $OUT)
    test $N -eq 629
    N=$(jq .database_info.postgres.count < $OUT_FROM_BIN)
    test $N -eq 629
}


@test "Consistent query_total" {
    N=$(jq .overall_stat.histogram.query_total < $OUT)
    test $N -eq 629
    N=$(jq .overall_stat.histogram.query_total < $OUT_FROM_BIN)
    test $N -eq 629
}


@test "Consistent peak.write" {
    N=$(jq '.overall_stat.peak."2017-09-06 08:49:19".write' < $OUT)
    test $N -eq 1
    N=$(jq '.overall_stat.peak."2017-09-06 08:49:19".write' < $OUT_FROM_BIN)
    test $N -eq 1
}
