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
    my @e = catch_missing_op($file);
    push @errors, sprintf "%s:%s", $file, join( ",", @e ) if @e;
}

is(
    @errors, 0,
    "The <form> in the following files are missing it's corresponding op parameter, or op does not start with 'cud-' (see bug 34478)"
) or diag( Dumper @errors );

sub catch_missing_op {
    my ($file) = @_;

    my @lines = read_file($file);
    my @errors;
    return unless grep { $_ =~ m|<form| } @lines;
    my ( $in_form, $line_open_form, $has_op, $op_value );
    my $line_number = 0;
    for my $line (@lines) {
        $line_number++;
        if ( $line =~ m{^(\s*)<form.*method=('|")post('|")}i ) {
            $in_form        = 1;
            $line_open_form = $line_number;
        }
        if ( $in_form && $line =~ m{name=('|")op('|")} ) {
            $has_op = 1;
            if ( $line =~ m{value=('|")([^'"]*)('|")} ) {
                $op_value = $2;
            }
        }
        if ( $in_form && $line =~ m{</form} ) {
            if ($has_op) {
                if ( $op_value !~ m{^cud-} && $op_value !~ m{^\[%} ) {
                    push @errors, $line_open_form;
                }
            } else {
                push @errors, $line_open_form;
            }
            $has_op  = 0;
            $in_form = 0;
        }
    }
    return @errors;
}
