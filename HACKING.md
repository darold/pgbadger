# Contributing on pgBadger

Thanks for your attention on pgBadger ! You need Perl Module JSON::XS
to run the full test suite. You can install it on a Debian like system
using:

    sudo apt-get install libjson-xs-perl

or in RPM like system using:

    sudo yum install perl-JSON-XS

pgBadger has a TAP compatible test suite executed by `prove`:

    $ prove
    t/01_lint.t ......... ok   
    t/02_basics.t ....... ok   
    t/03_consistency.t .. ok   
    All tests successful.
    Files=3, Tests=13,  6 wallclock secs ( 0.01 usr  0.01 sys +  5.31 cusr  0.16 csys =  5.49 CPU)
    Result: PASS
    $

or if you prefer to run test manually:

    $ perl Makefile.PL && make test
    Checking if your kit is complete...
    Looks good
    Generating a Unix-style Makefile
    Writing Makefile for pgBadger
    Writing MYMETA.yml and MYMETA.json
    cp pgbadger blib/script/pgbadger
    "/usr/bin/perl" -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pgbadger
    PERL_DL_NONLAZY=1 "/usr/bin/perl" "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(0, 'blib/lib', 'blib/arch')" t/*.t
    t/01_lint.t ......... ok   
    t/02_basics.t ....... ok   
    t/03_consistency.t .. ok   
    All tests successful.
    Files=3, Tests=13,  6 wallclock secs ( 0.03 usr  0.00 sys +  5.39 cusr  0.14 csys =  5.56 CPU)
    Result: PASS
    $ make clean && rm Makefile.old

Please contribute a regression test when you fix a bug or add a feature. Thanks!
