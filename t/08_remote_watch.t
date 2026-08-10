use strict;
use warnings;

use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use Test::More tests => 10;

my $tmpdir = tempdir(CLEANUP => 1);
my $fixture = abs_path('t/fixtures/remote_watch.csv');
my $mock_ssh = abs_path('t/fixtures/mock_ssh');
my $ssh_log = "$tmpdir/ssh.log";
my $report = "$tmpdir/report.txt";
my $pid_file = "$tmpdir/pgbadger.pid";
my $uri = "ssh://remote/$fixture";

local $ENV{PGBADGER_MOCK_SSH_LOG} = $ssh_log;
my $output = `perl pgbadger -q -w -f csv --pid-file '$pid_file' --ssh-command '$mock_ssh' -o '$report' '$uri' 2>&1`;

is($?, 0, 'remote CSV watch report succeeds') or diag($output);
ok(-s $report, 'remote CSV watch report is generated');

open(my $log_fh, '<', $ssh_log) or die "could not open $ssh_log: $!";
my $commands = do { local $/; <$log_fh> };
close($log_fh);

like($commands, qr/python3 -c/, 'remote CSV reader uses the CSV-aware filter');
like($commands, qr/row\[11\].*WARNING.*ERROR.*FATAL.*PANIC/, 'remote filter selects error severities');
unlike($commands, qr/ls -l/, 'filtered stream does not use the unfiltered file size');

open(my $report_fh, '<', $report) or die "could not open $report: $!";
my $report_content = do { local $/; <$report_fh> };
close($report_fh);

like($report_content, qr/second "quoted" error line/, 'multiline quoted CSV error remains parseable');

my $stderr_fixture = abs_path('t/fixtures/postgresql_param_range.log');
my $stderr_report = "$tmpdir/stderr-report.txt";
my $stderr_pid_file = "$tmpdir/stderr-pgbadger.pid";
my $stderr_uri = "ssh://remote/$stderr_fixture";

$output = `perl pgbadger -q -w -f stderr --pid-file '$stderr_pid_file' --ssh-command '$mock_ssh' -o '$stderr_report' '$stderr_uri' 2>&1`;
is($?, 0, 'remote stderr watch report succeeds') or diag($output);

open($log_fh, '<', $ssh_log) or die "could not open $ssh_log: $!";
$commands = do { local $/; <$log_fh> };
close($log_fh);
like($commands, qr/grep -E -A 200 'WARNING\|ERROR\|FATAL\|PANIC'/, 'remote text reader uses the error filter');

my $normal_ssh_log = "$tmpdir/normal-ssh.log";
my $normal_report = "$tmpdir/normal-report.txt";
my $normal_pid_file = "$tmpdir/normal-pgbadger.pid";
local $ENV{PGBADGER_MOCK_SSH_LOG} = $normal_ssh_log;

$output = `perl pgbadger -q -f csv --pid-file '$normal_pid_file' --ssh-command '$mock_ssh' -o '$normal_report' '$uri' 2>&1`;
is($?, 0, 'normal remote report succeeds') or diag($output);

open($log_fh, '<', $normal_ssh_log) or die "could not open $normal_ssh_log: $!";
$commands = do { local $/; <$log_fh> };
close($log_fh);
unlike($commands, qr/(?:python3 -c|grep -E -A 200)/, 'normal remote reader remains unfiltered');
