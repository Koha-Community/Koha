#!/usr/bin/perl

# Copyright 2024 Koha development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 3;
use Test::NoWarnings;
use File::Slurp;
use Data::Dumper;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new;
my @files     = $dev_files->ls_tt_files;

ok( @files > 0, 'We should test something' );

my @errors;
for my $file (@files) {
    my @e = check_csrf_in_forms($file);
    push @errors, sprintf "%s:%s", $file, join( ",", @e ) if @e;
}

is( @errors, 0, "The <form> in the following files are missing it's corresponding csrf_token include (see bug 22990)" )
    or diag( Dumper @errors );

sub check_csrf_in_forms {
    my ($file) = @_;

    my @lines = read_file($file);
    my @errors;
    return @errors unless grep { $_ =~ m|<form| } @lines;
    my ( $open, $found ) = ( 0, 0 );
    my $line_number = 0;
    for my $line (@lines) {
        $line_number++;
        $open = $line_number if $line =~ m{<form.*method=('|")post('|")}i;
        $found++ if $open && $line =~ m{csrf-token\.inc};
        if ( $open && $line =~ m{</form} ) {
            push @errors, $open unless $found;
            $found = 0;
            undef $open;
        }
    }
    return @errors;
}
