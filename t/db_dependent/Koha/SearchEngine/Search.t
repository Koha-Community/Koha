#!/usr/bin/perl

# Tests for Koha/SearchEngine/Search

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use MARC::Field;
use MARC::Record;
use Test::MockModule;
use Test::MockObject;

use t::lib::Mocks;

#use C4::Biblio qw//;
use Koha::Database;
use Koha::SearchEngine::Search;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'Test extract_biblionumber' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );
    my $biblio_mod  = Test::MockModule->new('C4::Biblio');
    my $search_mod  = Test::MockModule->new('C4::Search');
    my $koha_fields = [ '001', '' ];
    $biblio_mod->mock( 'GetMarcFromKohaField',  sub { return @$koha_fields; } );
    $search_mod->mock( 'new_record_from_zebra', \&test_record );

    # Extract using 001
    my $searcher = Koha::SearchEngine::Search->new;
    my $bibno    = $searcher->extract_biblionumber('fake_result');
    is( $bibno, 3456, 'Extracted biblio number for Zebra' );

    # Now use 999c with Elasticsearch
    t::lib::Mocks::mock_preference( 'SearchEngine', 'Elasticsearch' );
    $search_mod->unmock('new_record_from_zebra');
    $koha_fields = [ '999', 'c' ];
    $searcher    = Koha::SearchEngine::Search->new( { index => 'biblios' } );
    $bibno       = $searcher->extract_biblionumber( test_record() );
    is( $bibno, 4567, 'Extracted biblio number for Zebra' );
};

# -- Helper routine
sub test_record {
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '001', '3456' ),
        MARC::Field->new( '245', '', '', a => 'Some title' ),
        MARC::Field->new( '999', '', '', c => '4567' ),
    );
    return $marc;
}

$schema->storage->txn_rollback;
