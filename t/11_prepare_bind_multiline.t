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
	print $input "2026-10-12 12:00:00 UTC [105]: user=demo_user,db=demo_db,app=demo_app,client=example.test LOG:  duration: 2.000 ms  $action <unnamed>: SELECT\n";
	print $input "\t55 AS demo_middle,\n\t\n\t66 AS demo_tail;\n";
}
close($input);

my @args = ($^X, 'pgbadger', '-q', '--no-fork', '-f', 'stderr',
	'-p', '%t [%p]: user=%u,db=%d,app=%a,client=%h ',
	'--tempdir', $dir, '--pid-file', File::Spec->catfile($dir, 'pgbadger.pid'),
	'-o', $html, $log);
is(system(@args), 0, 'parse synthetic extended-protocol log');
open(my $output, '<', $html) or die $!;
my $report = do { local $/; <$output> };
close($output);
for my $action ('prepare', 'bind') {
	my ($table) = $report =~ m{(<table[^>]*id="time-consuming-$action-table".*?</table>)}s;
	like($table, qr/demo_middle.*demo_tail/s, "$action report retains multiline query");
}
like($report, qr/id="most-frequent-queries-table".*?demo_tail/s,
	'execute query is still complete');
done_testing();
