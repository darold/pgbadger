use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;

my $dir = tempdir(CLEANUP => 1);
my $log = File::Spec->catfile($dir, 'synthetic.log');
my $html = File::Spec->catfile($dir, 'report.html');
open(my $input, '>', $log) or die $!;
for my $action ('parse', 'bind', 'execute') {
	print $input "2026-10-12 12:00:00 UTC [105]: user=demo_user,db=demo_db,app=demo_app,client=example.test LOG:  duration: 2.000 ms  $action <unnamed>: SELECT 55 AS demo_value;\n";
}
close($input);
is(system($^X, 'pgbadger', '-q', '--no-fork', '-f', 'stderr',
	'-p', '%t [%p]: user=%u,db=%d,app=%a,client=%h ',
	'--tempdir', $dir, '--pid-file', File::Spec->catfile($dir, 'pgbadger.pid'),
	'-o', $html, $log), 0, 'generate report from synthetic log');
open(my $output, '<', $html) or die $!;
my $report = do { local $/; <$output> };
close($output);
for my $action ('prepare', 'bind') {
	my ($sample) = $report =~ m{id="time-consuming-$action-examples-rank-1"(.*?)</dl>}s;
	for my $field (['Database', 'demo_db'], ['User', 'demo_user'],
		['Remote', 'example.test'], ['Application', 'demo_app']) {
		like($sample, qr{\Q<b>$field->[0]:</b> $field->[1]\E}, "$action sample $field->[0]");
	}
	unlike($sample, qr/<b>Queryid:<\/b>/, "$action sample does not invent a query ID");
}
done_testing();
