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

use Test::More tests => 2;
use Test::Exception;

use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Database;

BEGIN {
    use_ok('Koha::Biblio::Metadatas');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'record() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $title = 'Oranges and Peaches';

    # Create a valid record
    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '245', '', '', 'a' => $title );
    $record->append_fields($field);
    my ($biblio_id) = C4::Biblio::AddBiblio( $record, '' );

    my $metadata = Koha::Biblios->find($biblio_id)->metadata;
    my $record2  = $metadata->record;

    is( ref $record2, 'MARC::Record', 'Method record() returned a MARC::Record object' );
    is( $record2->field('245')->subfield("a"),
        $title, 'Title in 245$a matches title from original record object' );

    my $bad_data = $builder->build_object(
        {   class => 'Koha::Biblio::Metadatas',
            value => { format => 'marcxml', schema => 'MARC21', metadata => 'this_is_not_marcxml' }
        }
    );

    throws_ok { $bad_data->record; }
    'Koha::Exceptions::Metadata::Invalid', 'Exception thrown on bad record';

    my $exception = $@;
    is( $exception->id,     $bad_data->id, 'id passed correctly to exception' );
    is( $exception->format, 'marcxml',     'format passed correctly to exception' );
    is( $exception->schema, 'MARC21',      'schema passed correctly to exception' );

    my $bad_format = $builder->build_object(
        {   class => 'Koha::Biblio::Metadatas',
            value => { format => 'mij', schema => 'MARC21', metadata => 'something' }
        }
    );

    throws_ok { $bad_format->record; }
    'Koha::Exceptions::Metadata', 'Exception thrown on unhandled format';

    is( "$@",
        'Koha::Biblio::Metadata->record called on unhandled format: mij',
        'Exception message built correctly'
    );

    $schema->storage->txn_rollback;
};
