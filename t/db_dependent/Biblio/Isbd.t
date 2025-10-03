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

use Test::NoWarnings;
use Test::More tests => 4;
use Test::MockModule;
use MARC::Record;
use t::lib::Mocks;

use Koha::Database;

BEGIN {
    use_ok( 'C4::Biblio', qw( GetISBDView ) );
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $template      = '#200|<h2>Title : |{200a}{ by 200f}|</h2>';
my $opac_template = '#200|<h2>Title : |{200a}{ (200f)}|</h2>';
t::lib::Mocks::mock_preference( 'isbd',     $template );
t::lib::Mocks::mock_preference( 'opacisbd', $opac_template );

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '200', '', '', 'a' => 'Mountains' ),
    MARC::Field->new( '200', '', '', 'f' => 'Keith Lye' ),
);

my $isbd = GetISBDView( { record => $record } );
is( $isbd, '<h2>Title : Mountains by Keith Lye</h2>', 'ISBD is correct' );

my $opacisbd = GetISBDView( { record => $record, template => 'opac' } );
is( $opacisbd, '<h2>Title : Mountains (Keith Lye)</h2>', 'OPAC ISBD is correct' );

$schema->storage->txn_rollback;
