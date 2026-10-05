use Test::More;
use JSON::XS;

plan tests => 8;

# Same execution reported by both log_min_duration_statement and auto_explain
# must be counted once and keep its explain plan.
my $json = JSON::XS->new;
my $LOG = 't/fixtures/explain_duplicate.log';
my $OUT = 't/explain_duplicate.json';
my $PFX = '%m [%p]: user=%u,db=%d,app=%a,client=%h,xid=%x ';

unlink $OUT;
my $ret = `perl pgbadger -q -p '$PFX' -x json -o $OUT $LOG 2>&1`;
is($?, 0, 'Generate json report');
diag($ret) if $?;

my $q = $json->decode(`cat $OUT`)->{normalyzed_info}{postgres};
my ($ta) = grep { /from ta / } keys %$q;
my ($tb) = grep { /from tb / } keys %$q;
my ($tc) = grep { /from tc / } keys %$q;

# plan message logged before the statement duration (simple query protocol)
is($q->{$ta}{count}, 1, 'Plan then statement of the same execution counted once');
ok((grep { $_->{plan} } values %{$q->{$ta}{samples}}), 'Plan kept in the sample');

# two distinct executions, one only reported by auto_explain, the other by log_min_duration_statement
is($q->{$tb}{count}, 2, 'Distinct executions are not merged');

# two executions each reported twice (statement then plan)
is($q->{$tc}{count}, 2, 'Two statement/plan pairs counted twice');
is($q->{$tc}{duration}, 5000.9, 'Duration taken from the statement messages');
is(scalar keys %{$q->{$tc}{samples}}, 2, 'One sample per execution');
is(scalar(grep { $_->{plan} } values %{$q->{$tc}{samples}}), 2, 'Plan attached to each sample');

unlink $OUT;
