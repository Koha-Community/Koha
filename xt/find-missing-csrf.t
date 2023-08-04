#!/usr/bin/perl

# Copyright 2021 Koha development team
#
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

use Modern::Perl;
use Test::More tests => 1;
use File::Find;
use File::Slurp;
use Data::Dumper;

my @themes;

# OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
for my $theme ( grep { not /^\.|lib|js|xslt/ } readdir($dh) ) {
    push @themes, "$opac_dir/$theme/en";
}
close $dh;

# STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
for my $theme ( grep { not /^\.|lib|js/ } readdir($dh) ) {
    push @themes, "$staff_dir/$theme/en";
}
close $dh;

my @files;
sub wanted {
    my $name = $File::Find::name;
    push @files, $name
        if $name =~ m[\.(tt|inc)$] and -f $name;
}

find({ wanted => \&wanted, no_chdir => 1 }, @themes );

my @errors;
for my $file ( @files ) {
    my @e = check_csrf_in_forms($file);
    push @errors, { file => $file, errors => \@e } if @e;
}

is( @errors, 0, "Template variables should be correctly escaped" )
    or diag(Dumper @errors);

sub check_csrf_in_forms {
    my ( $file ) = @_;

    my @lines = read_file($file);
    my @errors;
    return @errors unless grep { $_ =~ m|<form| } @lines;
    my ( $open, $found ) = ( 0, 0 );
    my $line = 0 ;
    for my $l (@lines) {
        $line++;
        $open = $line if ( $l =~ m{<form} && !( $l =~ m{method=('|")get('|")} ) );
        $found++  if ( $l =~ m|csrf\-token\.inc| && $open );
        if ( $open && $l =~ m|</form| ) {
            push @errors,
                "The <form> starting on line $open is missing it's corresponding csrf_token include (see bug 22990)"
                if !$found;
            $found = 0;
        }
    }
    return @errors;
}
