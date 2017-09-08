#!/usr/bin/env bats

@test "PERL syntax check" {
    perl -c pgbadger
}

@test "pod syntax check" {
    podchecker doc/*.pod
}
