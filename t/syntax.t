#!/usr/bin/env bats

@test "PERL syntax check" {
    perl -c pgbadger
}
