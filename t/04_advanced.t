use Test::Simple tests => 9;

my $GCPLOG = 't/fixtures/cloudsql.log.gz';
my $SYSLOG1 = 't/fixtures/pg-syslog.1.bz2';
my $SYSLOG2 = 't/fixtures/pg-syslog.1.bz2';
my $JSON = 't/out.json';
my $TEXT = 't/out.txt';

`rm t/cluster1_day_*.bin t/file_cluster1 2>/dev/null`;
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

$ret = `perl pgbadger -q --dbname=pgbench --explode -I -O $incr_outdir $SYSLOG1 $SYSLOG2 && ls $incr_outdir | grep ">12,474 queries" $incr_outdir/pgbench/20*/week-0*/index.html`;
chomp($ret);
ok( $? == 0 && ($ret ne ''), "Test incremental mode with --explode and --dbname");

$ret = `perl pgbadger -q --exclude-db cloudsqladmin --explode $GCPLOG && ls *.html | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 2), "Test database exclusion with jsonlog");

$ret = `perl pgbadger --disable-type --disable-session --disable-connection --disable-lock --disable-checkpoint --disable-autovacuum --disable-query -o out.txt t/fixtures/tempfile_only.log.gz -q`;
$ret = `grep "Example.*SELECT" out.txt | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret == 9), "Test log_temp_files only");

$ret = `perl pgbadger --last-parsed t/file_cluster1 -o t/cluster1_day_1.bin t/fixtures/tempfile_only.log.gz -q`;
$ret = `md5sum t/file_cluster1 | awk '{print \$1}'`;
chomp($ret);
ok( $? == 0 && ($ret eq "7faeb101abf32de3bc4e14fcf525e005" ), "Test last parse file without incremental mode");

$ret = `perl pgbadger --last-parsed t/file_cluster1 -o t/cluster1_day_2.bin t/fixtures/tempfile_only.log.gz -q`;
$ret = `ls -la t/cluster1_day_2.bin | awk '{print \$4}'`;
chomp($ret);
ok( $? == 0 && ($ret < 4000), "Second pass on last parse file without incremental mode");
$ret = `md5sum t/file_cluster1 | awk '{print \$1}'`;
chomp($ret);
ok( $? == 0 && ($ret eq "7faeb101abf32de3bc4e14fcf525e005" ), "Last parse file must not have changed");

# Remove files generated during the tests
`rm -f *.html`;
`rm -f out.txt`;
`rm -rf $incr_outdir`;
`rm t/cluster1_day_*.bin t/file_cluster1`;

