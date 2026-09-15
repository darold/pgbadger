use Test::More;

# Regression test: line filters such as --dbuser must not silently drop queries
# that belong to the requested user.
#
# On interleaved logs, a completed query can remain buffered in %cur_info for a
# backend after the line that would normally flush it has been removed by the
# filter. set_current_infos() then refuses to overwrite the still-occupied query
# slot, so the next query on that backend used to be dropped from the report.
#
# The fixture stages two concurrent "batch" backends (pids 100 and 200) plus one
# "webapp" line. With --dbuser=batch the webapp line is filtered out; that line is
# exactly the one that would have flushed pid 100's first query, so the following
# slow query on pid 100 (IMPORTANT_slow_batch_query) used to disappear.

plan tests => 8;

my $LOG    = 't/fixtures/dbuser_filter.log';
my $PREFIX = '%t:%r:%u@%d:[%p]:';
my $FILT   = 't/dbuser_filter_batch.html';
my $ALL    = 't/dbuser_filter_all.html';

unlink $FILT, $ALL;

# --- Filtered run: only the "batch" user -----------------------------------
my $ret = `perl pgbadger -q -f rds -p '$PREFIX' --dbuser=batch -o $FILT $LOG 2>&1`;
is($?, 0, 'Generate rds report filtered by --dbuser=batch');
diag($ret) if $?;

my $filtered = slurp($FILT);

like($filtered, qr/IMPORTANT_slow_batch_query/,
	'Slow batch query on a busy backend survives --dbuser filtering');
like($filtered, qr/stale_batch_query/,
	'Earlier batch query on the same backend is still reported');
like($filtered, qr/other_batch_query/,
	'Batch query on the second backend is reported');
unlike($filtered, qr/webapp/,
	'Non-matching user (webapp) is excluded by --dbuser=batch');

# --- Baseline run: no filter -----------------------------------------------
$ret = `perl pgbadger -q -f rds -p '$PREFIX' -o $ALL $LOG 2>&1`;
is($?, 0, 'Generate rds report without filter');
diag($ret) if $?;

my $all = slurp($ALL);
like($all, qr/IMPORTANT_slow_batch_query/,
	'Slow batch query is present in the unfiltered report');
like($all, qr/webapp/,
	'webapp user is present in the unfiltered report');

unlink $FILT, $ALL;

sub slurp {
	my ($file) = @_;
	open(my $fh, '<', $file) or return '';
	local $/;
	my $data = <$fh>;
	close($fh);
	return $data;
}
