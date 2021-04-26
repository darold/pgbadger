use Test::Simple tests => 5;

my $LOG1 = 't/fixtures/two.log';
my $LOG2 = 't/fixtures/three.log';

my $ret = `perl pgbadger --help`;
ok( $? == 0, "Inline help");

$ret = `perl pgbadger -q -o - --format txt --prefix '%m [%p]: user=%u,db=%d,app=%a,client=%h ' $LOG1 | grep "Total query duration:"`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total query duration: 184ms', "Total query duration detected");

$ret = `perl pgbadger -q -o - --format txt --prefix '%m [%p]: user=%u,db=%d,app=%a,client=%h ' $LOG1 | grep "Number of queries:"`;
chomp($ret);
ok( $? == 0 && $ret eq 'Number of queries: 1', "Query parsed");

$ret = `perl pgbadger -q -o - --format txt --prefix '%m [%p]: user=%u,db=%d,app=%a,client=%h ' $LOG2 | grep "Total query duration:"`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total query duration: 270ms', "Total query duration detected");

$ret = `perl pgbadger -q -o - --format txt --prefix '%m [%p]: user=%u,db=%d,app=%a,client=%h ' $LOG2 | grep "Number of queries:"`;
chomp($ret);
ok( $? == 0 && $ret eq 'Number of queries: 2', "Two queries have to be parsed");
