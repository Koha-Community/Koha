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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use File::Slurp qw( read_file );
use Test::More;
use Array::Utils qw( array_minus );

use Test::NoWarnings;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'core' } );
my @tt_files  = $dev_files->ls_tt_files;

# Only for staff
@tt_files = grep {m{/intranet-tmpl/}} @tt_files;

my @exceptions = qw(
    koha-tmpl/intranet-tmpl/prog/en/includes/main-container.inc
    koha-tmpl/intranet-tmpl/prog/en/includes/wrapper-staff-tool-plugin.inc
);

@tt_files = array_minus( @tt_files, @exceptions );

plan tests => scalar(@tt_files) + 1;

for my $file (@tt_files) {

    my @lines = read_file($file);
    my ( $has_main, $has_main_container_fluid );
    for my $line (@lines) {
        #$has_main_container_fluid = 1 if $line =~ m{<div class="main container-fluid">};
        $has_main = 1 if $line =~ m{<main>};
    }

    ok( !$has_main, qq{$file has '<main>', it must use main-container.inc instead.} );
    #is( $has_main_container_fluid, 0, qq{$file has '<div class="main container-fluid">', it must use main-container.inc instead.} );
}
