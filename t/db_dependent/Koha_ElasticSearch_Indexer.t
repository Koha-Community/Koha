# Copyright 2015 Catalyst IT
#
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

use strict;
use warnings;

use Test::More tests => 5;    # last test to print
use MARC::Record;

use_ok('Koha::ElasticSearch::Indexer');

my $indexer;
ok(
    $indexer = Koha::ElasticSearch::Indexer->new(
        {
            'nodes' => ['localhost:9200'],
            'index' => 'mydb'
        }
    ),
    'Creating new indexer object'
);

my $marc_record = MARC::Record->new();
my $field = MARC::Field->new( '001', '1234567' );
$marc_record->append_fields($field);
$field = MARC::Field->new( '020', '', '', 'a' => '1234567890123' );
$marc_record->append_fields($field);
$field = MARC::Field->new( '245', '', '', 'a' => 'Title' );
$marc_record->append_fields($field);

my $records = [$marc_record];
ok( my $converted = $indexer->_convert_marc_to_json($records),
    'Convert some records' );

is( $converted->count, 1, 'One converted record' );

ok( $indexer->update_index(undef,$records), 'Update Index' );
