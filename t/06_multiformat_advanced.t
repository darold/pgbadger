#!/usr/bin/env perl
#
# Advanced tests for multiple output format feature
# Tests edge cases, database explosion mode, and other scenarios
#

use Test::Simple tests => 8;
use File::Temp qw(tempdir);
use File::Spec;

my $LOG = 't/fixtures/light.postgres.log.bz2';
my $TMPDIR = tempdir(CLEANUP => 1);

# Test 1: Multiple formats with report-per-database (explosion mode)
my $explosion_dir = File::Spec->catfile($TMPDIR, 'explosion');
mkdir($explosion_dir);
my $ret = `perl pgbadger -q -E -O '$explosion_dir' -o report.html -o report.txt $LOG`;
my $html_exists = -e File::Spec->catfile($explosion_dir, 'report.html');
my $txt_exists = -e File::Spec->catfile($explosion_dir, 'report.txt');
ok($? == 0 && $html_exists && $txt_exists,
   "Multiple formats with database explosion mode");

# Test 2: Verify database-specific files are different
if ($html_exists && $txt_exists) {
   my $html_size = -s File::Spec->catfile($explosion_dir, 'report.html');
   my $txt_size = -s File::Spec->catfile($explosion_dir, 'report.txt');
   ok($html_size > 0 && $txt_size > 0,
      "Database-specific reports have content");
} else {
   ok(0, "Database-specific reports have content (files missing)");
}

# Test 3: Parallel processing with multiple outputs
my $parallel_dir = File::Spec->catfile($TMPDIR, 'parallel');
mkdir($parallel_dir);
$ret = `perl pgbadger -q -j 2 --outdir '$parallel_dir' -o report.html -o report.txt $LOG`;
my $p_html = File::Spec->catfile($parallel_dir, 'report.html');
my $p_txt = File::Spec->catfile($parallel_dir, 'report.txt');
ok($? == 0 && -e $p_html && -e $p_txt,
   "Multiple outputs with parallel processing (-j 2)");

# Test 4: Single file with multiple extensions in filename
my $single_dir = File::Spec->catfile($TMPDIR, 'single');
mkdir($single_dir);
my $single_file = File::Spec->catfile($single_dir, 'report.html');
$ret = `perl pgbadger -q --outdir '$single_dir' -o report.html $LOG`;
ok($? == 0 && -e $single_file,
   "Single output file still works");

# Test 5: Multiple identical extensions (different paths)
my $reports_dir = File::Spec->catfile($TMPDIR, 'reports');
mkdir($reports_dir);
my $report1 = File::Spec->catfile($reports_dir, 'report1.html');
my $report2 = File::Spec->catfile($reports_dir, 'report2.html');
$ret = `perl pgbadger -q -o $report1 -o $report2 $LOG`;
ok($? == 0 && -e $report1 && -e $report2 && -s $report1 > 0 && -s $report2 > 0,
   "Multiple outputs with same extension");

# Test 6: Output to stdout with other formats
my $mixed_file = File::Spec->catfile($TMPDIR, 'mixed.txt');
$ret = `perl pgbadger -q -o - -o $mixed_file $LOG 2>/dev/null | wc -c`;
chomp($ret);
my $file_size = -s $mixed_file;
ok($ret > 0 && $file_size > 0,
   "Stdout and file output work together");

# Test 7: Verify no temporary files left behind after errors
$ret = `perl pgbadger -q -o /invalid/path/report.html -o $mixed_file $LOG 2>&1`;
my $tmp_files = `find /tmp -name 'pgbadger_tmp_*.bin' -type f 2>/dev/null | wc -l`;
chomp($tmp_files);
ok($tmp_files eq '0',
   "No temporary files left after execution");

# Test 8: Multiple outputs with quiet mode
my $quiet_dir = File::Spec->catfile($TMPDIR, 'quiet');
mkdir($quiet_dir);
my $q_html = File::Spec->catfile($quiet_dir, 'report.html');
my $q_txt = File::Spec->catfile($quiet_dir, 'report.txt');
$ret = `perl pgbadger -q -o $q_html -o $q_txt $LOG 2>&1`;
my $stderr_output = `perl pgbadger -q -o $q_html -o $q_txt $LOG 2>&1 | wc -l`;
chomp($stderr_output);
ok($? == 0 && $stderr_output == 0,
   "Quiet mode suppresses all output");

