# Contributing on pgBadger

Thanks for your attention on pgBadger !

pgBadger has a TAP compatible test suite executed by `prove(1)` on CI. You can
write tests in many language including perl and bash.

    $ apt install bats
    ...
    $ prove
    t/basics.t .. ok 
    t/syntax.t .. ok 
    All tests successful.
    Files=2, Tests=4,  2 wallclock secs ( 0.02 usr  0.00 sys +  2.38 cusr  0.04 csys =  2.44 CPU)
    Result: PASS
    $

Please contribute a regression test when you fix a bug or add a feature. Thanks!
