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

use C4::Context;
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::Libraries;
use Koha::Patrons;

use Test::More tests => 4;

use_ok('Koha::Biblio');
use_ok('Koha::Biblios');

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my @branches = Koha::Libraries->search();
my $borrower = Koha::Patrons->search()->next();

my $biblio = MARC::Record->new();
$biblio->append_fields(
    MARC::Field->new( '100', ' ', ' ', a => 'Hall, Kyle' ),
    MARC::Field->new( '245', ' ', ' ', a => "Test Record", b => "Test Record Subtitle", b => "Another Test Record Subtitle" ),
);
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $biblio, '' );

my $field_mappings = Koha::Database->new()->schema()->resultset('Fieldmapping');
$field_mappings->delete();
$field_mappings->create( { field => 'subtitle', fieldcode => '245', subfieldcode => 'b' } );

$biblio = Koha::Biblios->find( $biblionumber );
my @subtitles = $biblio->subtitles();
is( $subtitles[0], 'Test Record Subtitle', 'Got first subtitle correctly' );
is( $subtitles[1], 'Another Test Record Subtitle', 'Got second subtitle correctly' );

$schema->storage->txn_rollback();

1;
