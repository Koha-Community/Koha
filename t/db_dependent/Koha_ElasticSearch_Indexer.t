# Copyright 2015 Catalyst IT
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

use Test::More tests => 5;

use MARC::Record;

use_ok('Koha::ElasticSearch::Indexer');

my $indexer;
ok(
    $indexer = Koha::ElasticSearch::Indexer->new({ 'index' => 'biblio' }),
    'Creating new indexer object'
);

my $marc_record = MARC::Record->new();
$marc_record->append_fields(
    MARC::Field->new( '001', '1234567' ),
    MARC::Field->new( '020', '', '', 'a' => '1234567890123' ),
    MARC::Field->new( '245', '', '', 'a' => 'Title' )
);

my $records = [$marc_record];
ok( my $converted = $indexer->_convert_marc_to_json($records),
    'Convert some records' );

is( $converted->count, 1, 'One converted record' );

SKIP: {

    eval { $indexer->get_elasticsearch_params; };

    skip 'ElasticSeatch configuration not available', 1
        if $@;

    ok( $indexer->update_index(undef,$records), 'Update Index' );
}

1;
