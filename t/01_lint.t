use Test::Simple tests => 3;

my $ret = `perl -wc pgbadger 2>&1`;
ok( $? == 0, "PERL syntax check");

$ret = `podchecker doc/*.pod 2>&1`;
ok( $? == 0, "pod syntax check");

$ret = `perl -E 'use Storable qw(dclone); say "version=",\$Storable::VERSION; say "limit=",\$Storable::recursion_limit; my \@tt; for (1..1_000_000) { my \$t = [[[]]]; push \@tt, \$t } dclone \@tt' 2>&1 | grep "Max. recursion depth with nested structures exceeded"`;
chomp($ret);
ok( $ret eq '', "Storable version in this Perl install is buggy, need Perl 5.32 or greater");

