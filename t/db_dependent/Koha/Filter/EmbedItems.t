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

use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::TestBuilder;

use C4::Biblio qw( GetMarcSubfieldStructure );

use Koha::Database;
use Koha::RecordProcessor;

my $schema  = Koha::Database->schema();
my $builder = t::lib::TestBuilder->new();

subtest 'EmbedItems tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin();

    # Add a biblio
    my $biblio = $builder->build_sample_biblio;
    foreach ( 1 .. 10 ) {
        $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    }

    my $mss      = C4::Biblio::GetMarcSubfieldStructure( '', { unsafe => 0 } );
    my $item_tag = $mss->{'items.itemnumber'}[0]->{tagfield};

    $biblio->discard_changes;
    my $record = $biblio->metadata->record;
    my @items  = $biblio->items->as_list;

    my $processor = Koha::RecordProcessor->new(
        {
            schema  => 'MARC',
            filters => ('EmbedItems'),
            options => { items => \@items }
        }
    );
    is( ref($processor), 'Koha::RecordProcessor', 'Created record processor' );

    my $result = $processor->process($record);
    is( ref($result), 'MARC::Record', 'It returns a reference to a MARC::Record object' );

    my @item_fields = $record->field($item_tag);

    is( scalar @item_fields, 10, 'One field for each item has been added' );

    is( $processor->process(), undef, 'undef returned if no record passed' );

    $schema->storage->txn_rollback();
};
