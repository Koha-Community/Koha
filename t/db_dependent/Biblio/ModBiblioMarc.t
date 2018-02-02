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

use Test::More tests => 1;
use t::lib::Mocks;
use t::lib::TestBuilder;
use MARC::Record;

use C4::Biblio;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest "Check MARC field length calculation" => sub {
    plan tests => 3;

    t::lib::Mocks->mock_preference( 'marcflavour', 'MARC21' );

    my $biblio = t::lib::TestBuilder->new->build({ source => 'Biblio' });
    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '100', '', '', a => 'My title' ),
    );

    is( $record->leader, ' 'x24, 'No leader lengths' );
    C4::Biblio::ModBiblioMarc( $record, $biblio->{biblionumber}, '' );
    my $savedrec = C4::Biblio::GetMarcBiblio({ biblionumber => $biblio->{biblionumber} });
    like( substr($savedrec->leader,0,5), qr/^\d{5}$/, 'Record length found' );
    like( substr($savedrec->leader,12,5), qr/^\d{5}$/, 'Base address found' );
};

$schema->storage->txn_rollback;
