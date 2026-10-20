use Test::More;
use File::Temp qw(tempdir);
use POSIX qw(strftime);

# Incremental mode with --explode (-E):
#  - #878: the calendar of the per-database global index must link to the
#          daily/weekly reports (reports must be named index.html).
#  - #881: database names must not escape the output directory nor collide
#          with LAST_PARSED or the year directories.
#  - #880: the retention (-R) must also remove per-database HTML reports.

plan tests => 15;

my $tmp = tempdir('pgbadger_explode_XXXX', TMPDIR => 1, CLEANUP => 1);

# Build a jsonlog file (database names are not restricted by a prefix regex)
sub gen_log
{
	my ($file, $start, $ndays, @dbs) = @_;
	open(my $fh, '>', $file) or die "can't write $file: $!";
	my $pid = 1000;
	for my $i (0 .. $ndays - 1)
	{
		my $day = strftime('%Y-%m-%d', gmtime($start + $i * 86400));
		foreach my $db (@dbs)
		{
			$pid++;
			(my $jdb = $db) =~ s/(["\\])/\\$1/g;
			print $fh qq({"timestamp":"$day 09:00:00.000 UTC","user":"app","dbname":"$jdb","pid":$pid,"remote_host":"10.0.0.1","session_id":"s$pid","line_num":1,"ps":"SELECT","error_severity":"LOG","message":"duration: 12.500 ms  statement: select $pid from t_$i","application_name":"psql","backend_type":"client backend","query_id":0}\n);
		}
	}
	close($fh);
}

sub slurp
{
	my ($file) = @_;
	open(my $fh, '<', $file) or return '';
	local $/;
	my $data = <$fh>;
	close($fh);
	return $data;
}

# 2026-07-01 00:00:00 UTC
my $t0 = 1782864000;

# --- #878 and #881 ------------------------------------------------------------
my $out = "$tmp/out";
mkdir $out;
gen_log("$tmp/a.log", $t0, 3, 'appdb', '../escaped', 'LAST_PARSED', '2025');
my $ret = `perl pgbadger -q -I -E -O $out -f jsonlog --start-monday $tmp/a.log 2>&1`;
is($?, 0, 'Incremental --explode run with unusual database names');
diag($ret) if $?;

ok(!-e "$tmp/escaped", 'Database "../escaped" does not write outside the output directory');
ok(-d "$out/%2E.%2Fescaped", 'Database "../escaped" is stored in an encoded directory');
ok(-f "$out/LAST_PARSED", 'LAST_PARSED is still a regular file');
ok(-d "$out/%4CAST_PARSED", 'Database "LAST_PARSED" is stored in an encoded directory');
ok(-d "$out/%32025", 'Numeric database name does not collide with year directories');
ok(-f "$out/appdb/2026/07/01/index.html", 'Daily report of a database is named index.html');

my $index = slurp("$out/appdb/index.html");
like($index, qr{href="2026/07/01/index\.html"}, 'Calendar links to the daily report');
like($index, qr{href="2026/week-\d+/index\.html"}, 'Calendar links to the weekly report');

# Second run must not die on directories of the previous run
gen_log("$tmp/b.log", $t0 + 3 * 86400, 1, 'appdb', '2025');
$ret = `perl pgbadger -q -I -E -O $out -f jsonlog --start-monday -R 2 $tmp/b.log 2>&1`;
is($?, 0, 'Second incremental run with retention succeeds');
diag($ret) if $?;

# --- #880 ---------------------------------------------------------------------
my $rout = "$tmp/retention";
mkdir $rout;
gen_log("$tmp/c.log", $t0, 70, 'appdb');
$ret = `perl pgbadger -q -I -E -O $rout -f jsonlog --start-monday -R 2 $tmp/c.log 2>&1`;
is($?, 0, 'Incremental --explode run over 10 weeks');
diag($ret) if $?;
ok(-d "$rout/appdb/2026/07", 'July HTML reports exist before cleanup');

gen_log("$tmp/d.log", $t0 + 70 * 86400, 1, 'appdb');
$ret = `perl pgbadger -q -I -E -O $rout -f jsonlog --start-monday -R 2 $tmp/d.log 2>&1`;
is($?, 0, 'Incremental --explode run with retention');
diag($ret) if $?;
ok(!-d "$rout/2026/07", 'Obsolete binary directory is removed');
ok(!-d "$rout/appdb/2026/07", 'Obsolete per-database HTML directory is removed');
