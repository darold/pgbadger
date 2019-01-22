use Test::Simple tests => 9;

my $LOG = 't/fixtures/light.postgres.log.bz2';
my $BIN = 't/fixtures/light.postgres.bin';
my $JSON = 't/out.json';
my $TEXT = 't/out.txt';

my $ret = `perl pgbadger --help`;
ok( $? == 0, "Inline help");

$ret = `perl pgbadger -q -o - $LOG`;
ok( $? == 0 && length($ret) > 0, "Light log report to stdout");

`rm -f out.html`;
$ret = `perl pgbadger -q --outdir '.' $LOG`;
ok( $? == 0 && -e "out.html", "Light log report to HTML");

$ret = `perl pgbadger -q -o $BIN $LOG`;
ok( $? == 0 && -e "$BIN", "Light log to binary");

`rm -f $JSON`;
$ret = `perl pgbadger -q -o $JSON --format binary $BIN`;
$ret = `cat $JSON | perl -pe 's/.*"SELECT":(\\d+),.*/\$1/'`;
ok( $? == 0 && $ret > 0, "From binary to JSON");

`mkdir t/test_incr/`;
$ret = `perl pgbadger -q -O t/test_incr -I --extra-files $LOG`;
ok( $? == 0 && -e "t/test_incr/2017/09/06/index.html"
	&& -e "t/test_incr/2017/week-37/index.html", "Incremental mode report");
$ret = `grep 'src="../../../.*/bootstrap.min.js"' t/test_incr/2017/09/06/index.html`;
ok( $? == 0 && substr($ret, 32, 14) eq 'src="../../../', "Ressources files in incremental mode");

`rm -f $JSON`;
$ret = `bunzip2 -c $LOG | perl pgbadger -q -o $JSON -`;
$ret = `cat $JSON | perl -pe 's/.*"SELECT":(\\d+),.*/\$1/'`;
ok( $? == 0 && $ret > 0, "Light log from STDIN");

$ret = `perl pgbadger -q --outdir '.' -o $TEXT -o $JSON -o - -x json $LOG > ret.json`;
$ret = `stat --printf='%s' ret.json out.json out.txt`;
chomp($ret);
ok( $? == 0 && $ret eq '13453413453415984', "Multiple output format");

# Remove files generated during the tests
`rm -f out.html`;
`rm -r $JSON`;
`rm -r $TEXT`;
`rm -f $BIN`;
`rm -rf t/test_incr/`;
`rm ret.json`

