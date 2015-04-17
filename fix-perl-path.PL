#!/usr/bin/perl
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#

use strict;
use ExtUtils::MakeMaker::Config;
use Tie::File;

my $basedir = (shift);
my $DEBUG = exists $ENV{'DEBUG'} ? $ENV{'DEBUG'} : 0;

$DEBUG = 1 if $basedir eq 'test';

my $bindir = $Config{installbin};
$bindir =~ s!\\!/!g;	# make all directory separators uniform since Win32 does not care and *nix does...
my $shebang = "#!$bindir\/perl";

warn "Perl binary located in $bindir on this system.\n" if $DEBUG;
warn "The shebang line for this sytems should be $shebang\n\n" if $DEBUG;

die if $basedir eq 'test';

=head1 NAME

fix-perl-path.PL - A script to correct the shebang line to match the current platform

=head1 SYNOPSIS

=head2 BASIC USAGE

    perl fix-perl-path.PL /absolute/path/to/foo

=head1 DESCRIPTION

This script should be run from the base of the directory
structure which contains the file(s) that need the
shebang line corrected. It will recurse through all
directories below the one called from and modify all
.pl files.

=head2 fixshebang

This sub will recurse through a given directory and its subdirectories checking for the existence of a shebang
line in .pl files and replacing it with the correct line for the current OS if needed. It should be called
in a manner similar to 'fixshebang (foodir)' but may be supplied with any directory.

=cut

sub fixshebang{
	my $dir = shift;
    opendir my $dh, $dir or die $!;
	warn "Reading $dir contents.\n" if $DEBUG;
    while( my $file = readdir($dh) ) {
		# this may be used to exclude any desired files from the scan
        # if ( $file =~ /foo/ ) { next; }
		# handle files... other extensions could be substituted/added if needed
		if ( $file =~ /\.pl$/ ) {
            my @filearray;
			my $pathfile =$dir . '/' . $file;
			warn "Found a perl script named $pathfile\n" if $DEBUG;

            # At this point, file is in 'blib' and by default
            # has mode a-w.  Therefore, must change permission
            # to make it writable.  Note that stat and chmod
            # (the Perl functions) should work on Win32
            my $old_perm;
            $old_perm = (stat $pathfile)[2] & 07777;
            my $new_perm = $old_perm | 0200;
            chmod $new_perm, $pathfile;

            # tie the file -- note that we're explicitly setting the line (record)
            # separator to hex 0A (the Unix newline) because that's what
            # the files copied to blib are using, regardless of whether the install
            # is under a Unix variant or Windows.
            tie @filearray, 'Tie::File', $pathfile, recsep => "\x0a" or die $!;

            warn "First line of $file is $filearray[0]\n\n" if $DEBUG;
			if ( ( $filearray[0] =~ /#!.*perl/ ) && ( $filearray[0] !~ /$shebang|"$shebang -w"/ ) ) {
				warn "\n\tRe-writing shebang line for $pathfile\n" if $DEBUG;
                warn "\tOriginal shebang line: $filearray[0]\n" if $DEBUG;
                $filearray[0] =~ /-w$/ ? $filearray[0] = "$shebang -w" : $filearray[0] = $shebang;
                warn "\tNew shebang line is: $filearray[0]\n\n" if $DEBUG;
			}
            elsif ( $filearray[0] =~ /$shebang|"$shebang -w"/ ) {
                warn "\n\tShebang line is correct.\n\n" if $DEBUG;
            }
			else {
                warn "\n\tNo shebang line found in $pathfile\n\n" if $DEBUG;
			}
            untie @filearray;
            chmod $old_perm, $pathfile;
		}
		# handle directories
		elsif ( -d ($dir . '/' . $file) && $file !~ /^\.{1,2}/ ) {
			my $dirpath = $dir . '/' . $file;
			warn "Found a subdir named $dirpath\n" if $DEBUG;
			fixshebang ($dirpath);
		}
	}
	closedir $dh;
}

fixshebang ($basedir);

