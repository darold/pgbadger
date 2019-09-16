use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use strict;

my @ALLOWED_ARGS = ('INSTALLDIRS','DESTDIR');

# Parse command line arguments and store them as environment variables
while ($_ = shift) {
	my ($k,$v) = split(/=/, $_, 2);
	if (grep(/^$k$/, @ALLOWED_ARGS)) {
		$ENV{$k} = $v;
	}
}
$ENV{DESTDIR} =~ s/\/$//;

# Default install path
my $DESTDIR = $ENV{DESTDIR} || '';
my $INSTALLDIRS = $ENV{INSTALLDIRS} || 'site';
my %merge_compat = ();

if ($ExtUtils::MakeMaker::VERSION >= 6.46) {
	%merge_compat = (
		'META_MERGE'   => {
			resources  => {
				homepage => 'http://pgbadger.darold.net/',
				repository  => {
					type => 'git',
					git => 'git@github.com:darold/pgbadger.git',
					web => 'https://github.com/darold/pgbadger',
				},
			},
		}
	);
}

sub MY::postamble {
    return <<'EOMAKE';
USE_MARKDOWN=$(shell which pod2markdown)

README: doc/pgBadger.pod
	pod2text $^ > $@
ifneq ("$(USE_MARKDOWN)", "")
	cat doc/pgBadger.pod | grep "=head1 " | sed 's/^=head1 \(.*\)/- [\1](#\1)/' | sed 's/ /-/g' | sed 's/--/- /' > $@.md
	sed -i '1s/^/### TABLE OF CONTENTS\n\n/' $@.md
	echo >> $@.md
	pod2markdown $^ | sed 's/^## /#### /' | sed 's/^# /### /' >> $@.md
endif

.INTERMEDIATE: doc/synopsis.pod
doc/synopsis.pod: Makefile pgbadger
	echo "=head1 SYNOPSIS" > $@
	./pgbadger --help >> $@
	echo "=head1 DESCRIPTION" >> $@
	sed -i.bak 's/ +$$//g' $@
	rm $@.bak

.PHONY: doc/pgBadger.pod
doc/pgBadger.pod: doc/synopsis.pod Makefile
	sed -i.bak '/^=head1 SYNOPSIS/,/^=head1 DESCRIPTION/d' $@
	sed -i.bak '4r $<' $@
	rm $@.bak
EOMAKE
}

WriteMakefile(
	'DISTNAME'	=> 'pgbadger',
	'NAME'		=> 'pgBadger',
	'VERSION_FROM'	=> 'pgbadger',
	'dist'  => {
			'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
			'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'
		   },
	'AUTHOR'       => 'Gilles Darold (gilles@darold.net)',
	'ABSTRACT'     => 'pgBadger - PostgreSQL log analysis report',
	'EXE_FILES'    => [ qw(pgbadger) ],
	'MAN1PODS'     => { 'doc/pgBadger.pod' => 'blib/man1/pgbadger.1p' },
	'DESTDIR'      => $DESTDIR,
	'INSTALLDIRS'  => $INSTALLDIRS,
	'clean'	       => {},
	%merge_compat
);
