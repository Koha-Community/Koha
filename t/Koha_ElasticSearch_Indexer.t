#
#===============================================================================
#
#         FILE: Koha_ElasticSearch_Indexer.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 09/12/13 08:57:25
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 5;    # last test to print
use MARC::Record;

use_ok('Koha::ElasticSearch::Indexer');

my $indexer;
ok(
    my $indexer = Koha::ElasticSearch::Indexer->new(
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
ok( my $converted = $indexer->convert_marc_to_json($records),
    'Convert some records' );

is( $converted->count, 1, 'One converted record' );

ok( $indexer->update_index($records), 'Update Index' );
