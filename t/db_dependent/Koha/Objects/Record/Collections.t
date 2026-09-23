#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

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
    my $collection = $result_set->print_collection( { format => 'marcxml' } );

    like( $collection, qr/<(\s*\w*:)?collection[^>]*>/, 'Has collection tag' );

    $result_set->reset;
    $collection = $result_set->print_collection( { format => 'mij' } );

    my $count = scalar( @{ decode_json($collection) } );

    is( $count, 2, 'Has 2 elements' );

    $result_set->reset;
    $collection = $result_set->print_collection( { format => 'marc' } );

    $count = $collection =~ tr/[\x1D]//;

    is( $count, 2, 'Has 2 USMARC end of record' );

    $result_set->reset;
    $collection = $result_set->print_collection( { format => 'txt' } );

    $count = scalar( split( /\n\n/, $collection ) );

    is( $count, 2, 'Has 2 records' );

    $schema->storage->txn_rollback;
};

subtest 'print_collection() embed_items tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $items_count = $biblio->items->count;

    my $result_set = Koha::Biblios->search( { biblionumber => $biblio->biblionumber } );

    # Without embed_items: no items embedded
    my $no_embed       = $result_set->print_collection( { format => 'marcxml' } );
    my $no_embed_count = () = $no_embed =~ m{tag="952"}g;
    is( $no_embed_count, 0, 'No item fields embedded when embed_items is not set' );

    # With embed_items: one 952 per item
    $result_set->reset;
    my $embedded = $result_set->print_collection(
        {
            format      => 'marcxml',
            embed_items => 1,
            interface   => 'intranet',
        }
    );
    my $embedded_count = () = $embedded =~ m{tag="952"}g;
    is( $embedded_count, $items_count, 'One item field embedded per item when embed_items is set' );

    $schema->storage->txn_rollback;
};
