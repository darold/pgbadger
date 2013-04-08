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
	'META_MERGE'   => {
		resources  => {
			homepage => 'http://projects.dalibo.org/pgbadger',
			repository  => {
				type => 'git',
				git => 'git@github.com:dalibo/pgbadger.git',
				web => 'https://github.com/dalibo/pgbadger',
			},
		},
        }
);

