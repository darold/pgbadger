#!/usr/bin/env perl
#
# Test suite for multiple output format feature in non-incremental mode
#

use Test::Simple tests => 10;
use File::Temp qw(tempdir);
use File::Spec;

my $LOG = 't/fixtures/light.postgres.log.bz2';
my $SYSLOG = 't/fixtures/pg-syslog.1.bz2';
my $TMPDIR = tempdir(CLEANUP => 1);

# Test 1: Generate two output formats (HTML and TXT)
my $html_file = File::Spec->catfile($TMPDIR, 'report.html');
my $txt_file = File::Spec->catfile($TMPDIR, 'report.txt');
my $ret = `perl pgbadger -q -o $html_file -o $txt_file $LOG`;
ok($? == 0 && -e $html_file && -e $txt_file,
   "Generate multiple outputs (HTML and TXT)");

# Test 2: Verify both files have content
my $html_size = -s $html_file;
my $txt_size = -s $txt_file;
ok($html_size > 0 && $txt_size > 0,
   "Both output files have content");

# Test 3: Verify HTML file contains expected HTML structure
$ret = `grep -q "<html" $html_file`;
ok($? == 0,
   "HTML file contains HTML structure");

# Test 4: Verify TXT file contains expected text structure
$ret = `grep -q "Global information" $txt_file`;
ok($? == 0,
   "Text file contains expected sections");

# Test 5: Generate three formats (HTML, TXT, and HTML with different name)
my $html2_file = File::Spec->catfile($TMPDIR, 'alternate.html');
$ret = `perl pgbadger -q -o $html2_file -o $txt_file -o $html_file $LOG`;
ok($? == 0 && -e $html_file && -e $html2_file && -e $txt_file,
   "Generate three output files (two HTML, one TXT)");

# Test 6: Test with syslog format
my $syslog_html = File::Spec->catfile($TMPDIR, 'syslog.html');
my $syslog_txt = File::Spec->catfile($TMPDIR, 'syslog.txt');
$ret = `perl pgbadger -q -o $syslog_html -o $syslog_txt $SYSLOG`;
ok($? == 0 && -e $syslog_html && -e $syslog_txt,
   "Generate multiple outputs from syslog format");

# Test 7: Verify files are different (HTML should be larger)
my $syslog_html_size = -s $syslog_html;
my $syslog_txt_size = -s $syslog_txt;
ok($syslog_html_size > $syslog_txt_size,
   "HTML output is larger than text output");

# Test 8: Test with output directory specified
my $out_dir = File::Spec->catfile($TMPDIR, 'reports');
mkdir($out_dir);
my $dir_html = File::Spec->catfile($out_dir, 'report.html');
my $dir_txt = File::Spec->catfile($out_dir, 'report.txt');
$ret = `perl pgbadger -q --outdir '$out_dir' -o report.html -o report.txt $LOG`;
ok($? == 0 && -e $dir_html && -e $dir_txt,
   "Multiple outputs with --outdir option");

# Test 9: Verify temporary binary file is cleaned up
$ret = `perl pgbadger -q -o $html_file -o $txt_file $LOG && find /tmp -name 'pgbadger_tmp_*.bin' -type f | wc -l`;
chomp($ret);
ok($ret eq '0',
   "Temporary binary file is cleaned up");

# Test 10: Test stdout option with multiple formats
$ret = `perl pgbadger -q -o - -o $txt_file $LOG 2>/dev/null`;
ok($? == 0 && length($ret) > 0 && -e $txt_file,
   "Stdout output works with multiple formats");

