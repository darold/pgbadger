use Test::More;
use JSON::XS;

plan tests => 6;

# Temporary files logged without a STATEMENT line are associated to the
# next query of the same backend. When that query spans several lines
# its first line must not be lost and the query must stay complete.
my $json = JSON::XS->new;
my $LOG = 't/fixtures/tempfile_multiline_query.log';
my $OUT = 't/tempfile_multiline_query.json';
my $PFX = '%m [%p]: user=%u,db=%d,app=%a,client=%h,xid=%x ';

unlink $OUT;

my $ret = `perl pgbadger -q -p '$PFX' -x json -o $OUT $LOG 2>&1`;
is($?, 0, 'Generate json report');
diag($ret) if $?;

my $json_ref = $json->decode(`cat $OUT`);
my $queries = $json_ref->{normalyzed_info}{postgres};
my @keys = keys %{$queries};

is(scalar @keys, 1, 'Single normalized query (no truncated duplicate)');
like($keys[0], qr/^select \* from t3 order by \?;$/, 'Normalized query is complete');
is($queries->{$keys[0]}{tempfiles}{size}, 2097152, 'Temporary file size attached to the complete query');

unlink $OUT;

# A temporary file logged after an "execute" message without duration
# (log_statement=all) must be associated to that query.
$LOG = 't/fixtures/tempfile_execute_no_duration.log';
$ret = `perl pgbadger -q -p '$PFX' -x json -o $OUT $LOG 2>&1`;
is($?, 0, 'Generate json report for execute without duration');
diag($ret) if $?;
$queries = $json->decode(`cat $OUT`)->{normalyzed_info}{postgres};
my ($k) = grep { /from t5/ } keys %{$queries};
is($queries->{$k}{tempfiles}{size}, 4096, 'Temporary file attached to the last execute query');
unlink $OUT;
