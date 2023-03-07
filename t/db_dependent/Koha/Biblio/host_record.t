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
use Data::Dumper qw/Dumper/;
use MARC::Field;
use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Koha::Database;
use Koha::Biblios;
use C4::Biblio;


my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;

subtest 'get_marc_host' => sub {
    plan tests => 18;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    t::lib::Mocks::mock_preference( 'MARCOrgCode', 'xyz' );

    my $bib1 = $builder->build_object({ class => 'Koha::Biblios' });
    my $bib2 = $builder->build_object({ class => 'Koha::Biblios' });
    my $item1 = $builder->build_object({ class => 'Koha::Items', value => { biblionumber => $bib2->biblionumber } });
    my $marc = MARC::Record->new;
    my $results = [];

    # Lets mock! Simulate search engine response and biblio metadata call.
    my $metadata = Test::MockObject->new;
    $metadata->mock( 'record', sub { return $marc; } );
    my $meta_mod = Test::MockModule->new( 'Koha::Biblio' );
    $meta_mod->mock( 'metadata', sub { return $metadata; } );
    my $engine = Test::MockObject->new;
    $engine->mock( 'simple_search_compat', sub { return ( undef, $results, scalar @$results ); } );
    $engine->mock( 'extract_biblionumber', sub { return $results->[0]; } );
    my $search_mod = Test::MockModule->new( 'Koha::SearchEngine::Search' );
    $search_mod->mock( 'new', sub { return $engine; } );

    # Case 1: Search engine does not return any results on controlnumber
    is( $bib1->get_marc_host, undef, 'Empty MARC record' );
    $marc->append_fields(
        MARC::Field->new( '773', '', '', g => 'relpart', w => '(xyz)123' ),
    );
    is( $bib1->get_marc_host, undef, '773 looks fine, but no search results' );

    # Case 2: Search engine returns (at maximum) one result
    $results = [ $bib1->biblionumber ]; # will be found because 773w is in shape
    my $host = $bib1->get_marc_host;
    is( ref( $host ), 'Koha::Biblio', 'Correct object returned' );
    is( $host->biblionumber, $bib1->biblionumber, 'Check biblionumber' );
    $marc->field('773')->update( w => '(xyz) bad data' ); # causes no results
    $host = $bib1->get_marc_host;
    is( $bib1->get_marc_host, undef, 'No results for bad 773' );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 1 );
    # no $w
    $marc->field('773')->update( t => 'title' );
    $marc->field('773')->delete_subfield( code => 'w' );
    $marc->field('773')->update( '0' => $bib2->biblionumber );
    $host = $bib1->get_marc_host;
    is( $host->biblionumber, $bib2->biblionumber, 'Found host biblio using 773$0 biblionumber' );

    $marc->field('773')->delete_subfield( code => '0' );
    $marc->field('773')->update( '9' => $item1->itemnumber );
    $host = $bib1->get_marc_host;
    is( $host->biblionumber, $bib2->biblionumber, 'Found host item using 773$9 itemnumber' );

    $marc->field('773')->delete_subfield( code => '9' );
    my ( $relatedparts, $info );
    ( $host, $relatedparts, $info ) = $bib1->get_marc_host;
    is( $host, undef, 'No Koha Biblio object returned with no $w' );
    is( $info, "title, relpart", '773$atg returned when no $w' );

    my $host_only = $bib1->get_marc_host_only;
    is_deeply( $host_only, $host, "Host only retrieved successfully" );
    my $relatedparts_only = $bib1->get_marc_relatedparts_only;
    is_deeply( $relatedparts_only, $relatedparts, "Related parts only retrieved successfully" );
    my $hostinfo_only = $bib1->get_marc_hostinfo_only;
    is_deeply( $hostinfo_only, $info, "Host info only retrieved successfully");

    $marc->field('773')->delete_subfield( code => 't' ); # restore

    # Add second 773
    $marc->append_fields( MARC::Field->new( '773', '', '', g => 'relpart2', w => '234' ) );
    $host = $bib1->get_marc_host;
    is( $host->biblionumber, $bib1->biblionumber, 'Result triggered by second 773' );
    # Replace orgcode
    ($marc->field('773'))[1]->update( w => '(abc)345' );
    is( $bib1->get_marc_host, undef, 'No results for two 773s' );
    # Test no_items flag
    ($marc->field('773'))[1]->update( w => '234' ); # restore
    $host = $bib1->get_marc_host({ no_items => 1 });
    is( $host->biblionumber, $bib1->biblionumber, 'Record found with no_items' );
    $builder->build({ source => 'Item', value => { biblionumber => $bib1->biblionumber } });
    is( $bib1->get_marc_host({ no_items => 1 }), undef, 'Record not found with no_items flag after adding one item' );
    # Test list context
    my @temp = $bib1->get_marc_host;
    is( $temp[1], 'relpart2', 'Return $g in list context' );

    # Case 3: Search engine returns more results
    $results = [ 1, 2 ];
    is( $bib1->get_marc_host, undef, 'get_marc_host returns undef for non-unique control number' );
};

sub mocked_search {
    my $results = shift;
    return ( undef, $results, scalar @$results );
}

$schema->storage->txn_rollback();
