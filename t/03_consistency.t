use Test::Simple tests => 34;
use JSON::XS;

my $json = new JSON::XS;

my $LOG = 't/fixtures/light.postgres.log.bz2 t/fixtures/pgbouncer.log.gz t/fixtures/pgbouncer.1.21.log.gz';
my $HLOG = 't/fixtures/logplex.gz';
my $RDSLOG = 't/fixtures/rds.log.bz2';
my $GCPLOG = 't/fixtures/cloudsql.log.gz';
my $CNPGLOG = 't/fixtures/cnpg.log.gz';
my $TIMELOG = 't/fixtures/begin_end.log';
my $VACUUMLOG = 't/fixtures/pg_vacuums.log.gz';
my $VACUUMJSON = 't/fixtures/pg_vacuums.json.gz';
my $BIN = 'out.bin';
my $OUT = 'out.json';

my $ret = `perl pgbadger -q -o $BIN $LOG`;
ok( $? == 0, "Generate intermediate binary file from log");

$ret = `perl pgbadger -q -o $OUT --format binary $BIN`;
ok( $? == 0, "Generate json report from binary file");
`cp $OUT /tmp/`;

`rm -f $BIN`;

my $json_ref = $json->decode(`cat $OUT`);

#
# Assert that analyzing json file provide the right results
#
ok( $json_ref->{database_info}{postgres}{postgres}{count} == 629, "Consistent count");

ok( $json_ref->{overall_stat}{postgres}{histogram}{query_total} == 629, "Consistent query_total");

ok( $json_ref->{overall_stat}{postgres}{peak}{"2017-09-06 08:48:45"}{write} == 1, "Consistent peak write");

ok( $json_ref->{pgb_session_info}{chronos}{20180912}{16}{count} == 63943, "pgBouncer connections");

$ret = `ls -la $OUT | awk '{print \$5}'`;
chomp($ret);
ok( $ret == 229293, "Consistent pgbouncer reports $ret != 229293");

`rm -f $OUT`;

$ret = `perl pgbadger -q -o $OUT $HLOG`;
ok( $? == 0, "Generate json report for heroku log file");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{database_info}{postgres}{GREEN}{"cte|duration"} eq "21761.546", "Consistent CTE duration");

# check logplex multiline and new format
$ret = `grep -E "WHERE missions.checker_id = " out.json | wc -l`;
chomp($ret);
ok( $ret == 1, "logplex multiline and new format");

`rm -f $OUT`;

$ret = `perl pgbadger -q -o $OUT --exclude-client 192.168.1.201 $RDSLOG`;
ok( $? == 0, "Generate json report from RDS log file with --exclude-client");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{normalyzed_info}{postgres}{'select datname from pg_database where not datistemplate and datallowconn;'}{duration} eq "2.667", "Consistent RDS + exclude client");

`rm -f $OUT`;

$ret = `perl pgbadger -q -o $OUT $GCPLOG`;
ok( $? == 0, "Generate json report from CloudSQL log file");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{connection_info}{postgres}{database_user}{cloudsqladmin}{cloudsqladmin} eq "151", "Consistent CloudSQL log format");

`rm -f $OUT`;

$ret = `perl pgbadger -q -o $OUT $CNPGLOG`;
ok( $? == 0, "Generate json report from CloudNativePG log file");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{connection_info}{postgres}{database_user}{postgres}{postgres} eq "378", "Consistent CloudNativePG log format");

`rm -f $OUT`;

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --begin "09:00:00" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 4', "Generate report from begin time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --end "20:30:00" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 6', "Generate report from end time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --begin "09:00:00" --end "20:30:00" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 2', "Generate report from begin->end time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --end "2021-02-15 20:30:00" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 7', "Generate report from full log before with end time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --end "2021-02-14 20:30:00" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 3', "Generate report from single day before with end time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --include-time "2021-02-14 2[01]:.*" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 2', "Generate report from include time");

$ret = `perl pgbadger -q -p "%t [%p]: db=%d,user=%u,app=%a,client=%h " -o - $TIMELOG --exclude-time "2021-02-14 2[01]:.*" | grep '^Total number of sessions:'`;
chomp($ret);
ok( $? == 0 && $ret eq 'Total number of sessions: 6', "Generate report from exclude time");

$ret = `perl pgbadger -q --log-timezone +5 -p "%t:%h:%u@%d:[%p]:" -o - t/fixtures/pg-timezones.log`;
chomp($ret);
ok( $? == 0 && $ret =~ m{Log start from 2021-05-27 12:00:00 to 2021-05-27 12:46:39} , "Correct first and last query timestamps on timezone adjusted log");

$ret = `perl pgbadger -f stderr -q -p "%t [%p]: [%l-1] user=%u,db=%d,host=%h,app=%a" -o $OUT $VACUUMLOG`;
ok( $? == 0, "Generate vacuums report from stderr log");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{autoanalyze_info}{postgres}{count} eq "1450", "Autoanalyze count stderrlog");
ok( $json_ref->{autoanalyze_info}{postgres}{chronos}{"20240627"}{"01"}{count} eq "474", "Autoanalyze count at 01 am stderrlog");
ok( $json_ref->{autovacuum_info}{postgres}{count} eq "2094", "Autovacuum count stderrlog");
ok( $json_ref->{autovacuum_info}{postgres}{chronos}{"20240627"}{"02"}{count} eq "730", "Autovacuum count at 2 am stderrlog");
`rm -f $OUT`;

$ret = `perl pgbadger -f jsonlog -q -x json -o $OUT $VACUUMJSON`;
ok( $? == 0, "Generate vacuums report from jsonlog");
$json_ref = $json->decode(`cat $OUT`);
ok( $json_ref->{autoanalyze_info}{postgres}{count} eq "1450", "Autoanalyze count jsonlog");
ok( $json_ref->{autoanalyze_info}{postgres}{chronos}{"20240627"}{"01"}{count} eq "474", "Autoanalyze count at 01 am jsonlog");
ok( $json_ref->{autovacuum_info}{postgres}{count} eq "2094", "Autovacuum count jsonlog");
ok( $json_ref->{autovacuum_info}{postgres}{chronos}{"20240627"}{"02"}{count} eq "730", "Autovacuum count at 2 am jsonlog");
`rm -f $OUT`;
