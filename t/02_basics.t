use Test::Simple tests => 17;

my $LOG = 't/fixtures/light.postgres.log.bz2';
my $SYSLOG = 't/fixtures/pg-syslog.1.bz2';
my $BIN = 't/fixtures/light.postgres.bin';
my $ANON = 't/fixtures/anonymize.log';
my $JSON = 't/out.json';
my $TEXT = 't/out.txt';
my $WEEKDAYLOG = 't/fixtures/weeknumber.log';

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
$ret = `cat $JSON | perl -pe 's/.*"select":([1-9]+),.*/\$1/'`;
ok( $? == 0 && $ret > 0, "From binary to JSON");

`mkdir t/test_incr/`;
$ret = `perl pgbadger -q -O t/test_incr -I --extra-files $LOG`;
ok( $? == 0 && -e "t/test_incr/2017/09/06/index.html"
	&& -e "t/test_incr/2017/week-37/index.html", "Incremental mode report");
$ret = `grep 'src="../../../.*/bootstrap.min.js"' t/test_incr/2017/09/06/index.html`;
ok( $? == 0 && substr($ret, 32, 14) eq 'src="../../../', "Ressources files in incremental mode");

`rm -f $JSON`;
$ret = `bunzip2 -c $LOG | perl pgbadger -q -o $JSON -`;
$ret = `cat $JSON | perl -pe 's/.*"select":([1-9]+),.*/\$1/'`;
ok( $? == 0 && $ret > 0, "Light log from STDIN");

$ret = `perl pgbadger -q --outdir '.' -o $TEXT -o $JSON -o - -x json $LOG > t/ret.json`;
my $ret2 = `stat --printf='%s' t/ret.json $TEXT $JSON`;
chomp($ret);
ok( $? == 0 && $ret2 eq '13478015985134780', "Multiple output format '$ret2' = '13478015985134780'");

$ret = `perl pgbadger -q -o - $SYSLOG`;
ok( $? == 0 && (length($ret) >= 24060), "syslog report to stdout");

$ret = `perl pgbadger -q -f stderr -o /tmp/report$$.txt t/fixtures/stmt_type.log`;
$ret = `grep -E "^(SELECT|INSERT|UPDATE|DELETE|COPY|CTE|DDL|TCL|CURSOR)" /tmp/report$$.txt > /tmp/stmt_type.out`;
$ret = `diff t/exp/stmt_type.out /tmp/stmt_type.out`;
ok( $? == 0 && ($ret eq ''), "statement type");

$ret = `grep "forêt & océan" /tmp/report$$.txt |wc -l`;
chomp($ret);
ok( $? == 0 && ($ret eq '7'), "French encoding");

$ret = `grep "камень & почка" /tmp/report$$.txt | wc -l`;
chomp($ret);
ok( $? == 0 && ($ret eq '7'), "Cyrillic encoding");

`rm /tmp/report$$.txt`;

# Test CSV and anonymization only if Text::CSV_XS is installed
`perl -MText::CSV_XS -e 1 2>/dev/null`;
if ($? == 0)
{
	$ret = `perl pgbadger -m 1000 -q -f csv --anonymize -o /tmp/report$$.txt $ANON`;
	$ret = `grep "11111111" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #1");
	$ret = `grep "'r','p','v','f','m'" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #2");
	$ret = `grep "x255044" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #3");
}
else
{
	$ret = `perl pgbadger -q -f csv --anonymize -o /tmp/report$$.txt $SYSLOG`;
	$ret = `grep "aid = 62643" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #1");
	$ret = `grep "tid = 1;" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #2");
	$ret = `grep "8, 1, 27361, 529, CURRENT_TIMESTAMP" /tmp/report$$.txt | wc -l`;
	chomp($ret);
	ok( $? == 0 && ($ret eq '0'), "Anonymization #3");
}

my $incr_outdir = "/tmp/pgbadger_data_tmp";
mkdir($incr_outdir);
$ret = `perl pgbadger -q --iso-week-number -X -I -O $incr_outdir -f csv $WEEKDAYLOG && ls $incr_outdir/2021/ | grep -E '(week-27|week-53)' | wc -l`;
chomp($ret);

ok( $? == 0 && $ret eq '2');
# Remove files generated during the tests
`rm -f out.html`;
`rm -r $JSON`;
`rm -r $TEXT`;
`rm -f $BIN`;
`rm -rf t/test_incr/`;
`rm t/ret.json`;
`rm /tmp/report$$.txt`;
`rm /tmp/stmt_type.out`;
`rm -rf $incr_outdir`;

