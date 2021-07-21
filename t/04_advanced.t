use Test::Simple tests => 5;

my $GCPLOG = 't/fixtures/cloudsql.log.gz';
my $SYSLOG1 = 't/fixtures/pg-syslog.1.bz2';
my $SYSLOG2 = 't/fixtures/pg-syslog.1.bz2';
my $JSON = 't/out.json';
my $TEXT = 't/out.txt';

`rm *.html 2>/dev/null`;
my $ret = `perl pgbadger -q --exclude-db=pgbench --explode $SYSLOG1 && ls *.html`;
chomp($ret);
ok( $? == 0 && ($ret eq "out.html"), "Test --exclude-db + --explode");

$ret = `perl pgbadger -q --dbname=pgbench --explode $SYSLOG1 && ls *.html`;
chomp($ret);
ok( $? == 0 && ($ret eq "pgbench_out.html"), "Test --dbname + --explode");

`rm *.html`;

my $incr_outdir = "/tmp/pgbadger_data_tmp";
mkdir($incr_outdir);

$ret = `perl pgbadger -q --explode -I -O $incr_outdir $SYSLOG1 $SYSLOG2 && ls $incr_outdir | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 4), "Test incremental mode with --explode");

`rm -rf $incr_outdir/*`;

$ret = `perl pgbadger -q --dbname=pgbench --explode -I -O $incr_outdir $SYSLOG1 $SYSLOG2 && ls $incr_outdir | grep ">12,474 queries" $incr_outdir/pgbench/2021/week-07/index.html`;
chomp($ret);
ok( $? == 0 && ($ret ne ''), "Test incremental mode with --explode and --dbname");

$ret = `perl pgbadger -q --exclude-db cloudsqladmin --explode $GCPLOG && ls *.html | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 2), "Test database exclusion with jsonlog");

# Remove files generated during the tests
`rm -f *.html`;
`rm -rf $incr_outdir`;

