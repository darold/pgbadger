use Test::Simple tests => 5;
use JSON::XS;

my $json = new JSON::XS;

my $LOG = 't/fixtures/light.postgres.log.bz2';
my $BIN = 'out.bin';
my $OUT = 'out.json';

my $ret = `perl pgbadger -q -o $BIN $LOG`;
ok( $? == 0, "Generate intermediate binary file from log");

$ret = `perl pgbadger -q -o $OUT --format binary $BIN`;
ok( $? == 0, "Generate json report from binary file");

`rm -f $BIN`;

my $json_ref = $json->decode(`cat $OUT`);

#
# Assert that analyzing json file provide the right results
#
ok( $json_ref->{database_info}{postgres}{count} == 629, "Consistent count");

ok( $json_ref->{overall_stat}{histogram}{query_total} == 629, "Consistent query_total");

ok( $json_ref->{overall_stat}{peak}{"2017-09-06 08:48:45"}{write} == 1, "Consistent peak write");

`rm -f $OUT`;

