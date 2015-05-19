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

use Modern::Perl;

use CGI;

use Test::More tests => 5;
use Test::Deep;

BEGIN {
    use_ok( 'C4::Templates' );
    can_ok( 'C4::Templates',
         qw/ GetColumnDefs
             getlanguagecookie
             setlanguagecookie
             themelanguage
             gettemplate
             _get_template_file
             param
             output /);
}

my $query   = CGI->new();
my $columns = C4::Templates::GetColumnDefs( $query );

is( ref( $columns ) eq 'HASH', 1, 'GetColumnDefs returns a hashref' );
# get the tables names, sorted
my @keys = sort keys %$columns;
is( scalar @keys, 6, "GetColumnDefs correctly returns the 5 tables defined in columns.def" );
my @tables = ( 'biblio', 'biblioitems', 'borrowers', 'items', 'statistics', 'subscription');
cmp_deeply( \@keys, \@tables, "GetColumnDefs returns the expected tables");


1;
