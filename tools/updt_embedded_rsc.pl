#!/usr/bin/env perl
#-----------------------------------------------------------------------------
#
# Script used to update javascript and css files embedded into pgbadger.
# It will replace all content after the __DATA__ in the right order with
# the files content stored into the resources/min/ directory.
#
# This script must be executed from the main source repository as follow:
# 	
# This script must be executed from the main source repository as follow:
# 	./tools/updt_embedded_rsc.pl
#
# The fontawesome.css must also embedded the TrueType font, this is done
#-----------------------------------------------------------------------------
use strict;

my $RSC_DIR       = 'resources';
my $PGBADGER_PROG = 'pgbadger';
my $DEST_TMP_FILE = 'pgbadger.new';

# Ordered resources files list
my @rsc_list = qw(jquery.jqplot.css jquery.js jquery.jqplot.js jqplot.pieRenderer.js jqplot.barRenderer.js jqplot.dateAxisRenderer.js jqplot.canvasTextRenderer.js jqplot.categoryAxisRenderer.js jqplot.canvasAxisTickRenderer.js jqplot.highlighter.js jqplot.highlighter.js jqplot.cursor.js jqplot.pointLabels.js bean.js underscore.js bootstrap.css fontawesome.css bootstrap.js pgbadger_slide.js pgbadger.css pgbadger.js);
my @min_rsc_list = ();

if (!-d $RSC_DIR) {
	die "FATAL: can't find directory: $RSC_DIR.\n";
}

# Apply patch on jquery.jqplot.js to fix infinite loop
# May be removed with next jqplot release update
`patch -r - -s  -N resources/jquery.jqplot.js -i resources/patch-jquery.jqplot.js`;

# Generate all minified resources files
mkdir "$RSC_DIR/min";
foreach my $f (@rsc_list) {
	my $dest = $f;
	$dest =~ s/\.(js|css)$/.min.$1/;
	push(@min_rsc_list, $dest);
	# minify resources files
	`yui-compressor $RSC_DIR/$f -o $RSC_DIR/min/$dest`;
}

# Embedded fontawesome webfont into the CSS file as base64 data
print `base64 -w 0 $RSC_DIR/font/FontAwesome.otf > $RSC_DIR/font/FontAwesome.otf.b64`;
open(IN, "$RSC_DIR/font/FontAwesome.otf.b64") or die "FATAL: can't open file $RSC_DIR/font/FontAwesome.otf.b64, $!\n";
my $b64_font = <IN>;
close(IN);

# Update minimized fontawesome.css file
open(IN, "$RSC_DIR/min/fontawesome.min.css") or die "FATAL: can't open file $RSC_DIR/min/fontawesome.min.css\n";
my @content = <IN>;
close(IN);
open(OUT, ">$RSC_DIR/min/fontawesome.min.css") or die "FATAL: can't write to file $RSC_DIR/min/fontawesome.min.css\n";
foreach my $l (@content) {
	$l =~ s|;src:url.* format.* format\('svg'\);|;src: url('data:font\/opentype;charset=utf-8;base64,$b64_font') format('truetype');|;
	print OUT $l;
}
close(OUT);

if (!-e $PGBADGER_PROG) {
	die "FATAL: can't find pgbadger script: $PGBADGER_PROG\n";
}

# Extract content of pgbadger script until __DATA__ is found
my $content = '';
open(IN, $PGBADGER_PROG) or die "FATAL: can't open file $PGBADGER_PROG, $!\n";
while (<IN>) {
	last if (/^__DATA__$/);
	$content .= $_;
}
close(IN);

# Write script base to destination file
open(OUT, ">$DEST_TMP_FILE") or die "FATAL: can't write to file $DEST_TMP_FILE, $!\n";
print OUT $content;
print OUT "__DATA__\n";

# Append each minified resources file
foreach my $f (@min_rsc_list) {
	print OUT "\nWRFILE: $f\n\n";
	open(IN, "$RSC_DIR/min/$f") or die "FATAL: can't open file $RSC_DIR/min/$f, $!\n";
	my @tmp = <IN>;
	close(IN);
	print OUT @tmp;
}
close(OUT);

# Clobber original pgbadger file.
rename($DEST_TMP_FILE, $PGBADGER_PROG) or die "FATAL: can't rename $DEST_TMP_FILE into $PGBADGER_PROG\n";

exit 0;
