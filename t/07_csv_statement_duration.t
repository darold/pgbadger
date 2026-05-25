use Test::More;
use JSON::XS;

eval { require Text::CSV_XS; 1 }
	or plan skip_all => 'Text::CSV_XS is required for csvlog parsing';

plan tests => 5;

my $json = JSON::XS->new;
my $LOG = 't/fixtures/csv_statement_without_duration.log';
my $OUT = 't/csv_statement_without_duration.json';

unlink $OUT;

my $ret = `perl pgbadger -f csv -q -x json -o $OUT $LOG 2>&1`;
is($?, 0, 'Generate json report from csvlog');
diag($ret) if $?;

my $json_ref = $json->decode(`cat $OUT`);
my $queries = $json_ref->{normalyzed_info}{postgres};
my ($statement_key) = grep { /health_check/ } keys %{$queries};
my ($duration_key) = grep { /slow_table/ } keys %{$queries};

ok($duration_key, 'Fixture contains a duration-bearing query');
is($queries->{$duration_key}{duration}, '688786.283', 'Duration-bearing query keeps its duration');
ok($statement_key, 'Fixture contains a statement-only query');
ok(
	!exists $queries->{$statement_key}{duration}
		&& !exists $queries->{$statement_key}{min}
		&& !exists $queries->{$statement_key}{max},
	'Statement-only csvlog query does not inherit previous duration'
);

unlink $OUT;
