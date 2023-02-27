#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 1;

use Koha::Biblios;
use Koha::Database;
use JSON qw( decode_json );

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'print_collection() tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Two biblios
    my $biblio_1 = $builder->build_sample_biblio;
    my $biblio_2 = $builder->build_sample_biblio;

    my $result_set = Koha::Biblios->search(
        [
            { biblionumber => $biblio_1->biblionumber },
            { biblionumber => $biblio_2->biblionumber }
        ]
    );
    my $collection = $result_set->print_collection('marcxml');

    like( $collection, qr/<(\s*\w*:)?collection[^>]*>/, 'Has collection tag' );

    $result_set->reset;
    $collection = $result_set->print_collection('mij');

    my $count = scalar( @{ decode_json($collection) } );

    is( $count, 2, 'Has 2 elements' );

    $result_set->reset;
    $collection = $result_set->print_collection('marc');

    $count = $collection =~ tr/[\x1D]//;

    is( $count, 2, 'Has 2 USMARC end of record' );

    $result_set->reset;
    $collection = $result_set->print_collection('txt');

    $count = scalar( split( /\n\n/, $collection ) );

    is( $count, 2, 'Has 2 records' );

    $schema->storage->txn_rollback;
};
