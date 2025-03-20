#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 13;

use Koha::Acquisition::Baskets;    # Koha::Acquisition::Baskets uses the mixin
use Koha::AdditionalFields;
use Koha::AdditionalFieldValues;
use Koha::Database;

use t::lib::TestBuilder;

my $storage = Koha::Database->new->schema->storage;
$storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $basket1 = $builder->build_object(
    {
        class => 'Koha::Acquisition::Baskets',
    }
);
my $basket2 = $builder->build_object(
    {
        class => 'Koha::Acquisition::Baskets',
    }
);

my $foo = Koha::AdditionalField->new(
    {
        tablename => 'aqbasket',
        name      => 'basket_foo',
    }
)->store;
my $bar = Koha::AdditionalField->new(
    {
        tablename => 'aqbasket',
        name      => 'basket_bar',
    }
)->store;

Koha::AdditionalFieldValue->new(
    {
        field_id  => $foo->id,
        record_id => $basket1->basketno,
        value     => 'foo value for basket1',
    }
)->store;
Koha::AdditionalFieldValue->new(
    {
        field_id  => $bar->id,
        record_id => $basket1->basketno,
        value     => 'bar value for basket1',
    }
)->store;

my $additional_fields_for_basket2 = [
    {
        id    => $foo->id,
        value => 'foo value for basket2',
    },
    {
        id    => $bar->id,
        value => 'bar value for basket2',
    },
];
$basket2->set_additional_fields($additional_fields_for_basket2);

my $additional_fields = $basket2->additional_field_values;
is(
    ref($additional_fields), 'Koha::AdditionalFieldValues',
    '->additional_field_values should return a Koha::AdditionalFieldValues object'
);
is_deeply(
    [
        map {
            {
                # We are basically removing the 'id' field here
                field_id  => $_->{field_id},
                record_id => $_->{record_id},
                value     => $_->{value},
            }
        } sort { $a->{id} <=> $b->{id} } @{ $additional_fields->unblessed }
    ],
    [
        {
            field_id  => $additional_fields_for_basket2->[0]->{id},
            record_id => $basket2->basketno,
            value     => $additional_fields_for_basket2->[0]->{value},
        },
        {
            field_id  => $additional_fields_for_basket2->[1]->{id},
            record_id => $basket2->basketno,
            value     => $additional_fields_for_basket2->[1]->{value},
        }

    ],
    '->additional_field_values should return the correct values'
);

my @baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo value for basket1',
        },
    ]
)->as_list;

is( scalar @baskets,       1,                  'search returns only one result' );
is( $baskets[0]->basketno, $basket1->basketno, 'result is basket1' );

@baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo value for basket2',
        },
    ]
)->as_list;

is( scalar @baskets,       1,                  'search returns only one result' );
is( $baskets[0]->basketno, $basket2->basketno, 'result is basket2' );

@baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo value for basket1',
        },
        {
            id    => $bar->id,
            value => 'bar value for basket1',
        },
    ]
)->as_list;

is( scalar @baskets,       1,                  'search returns only one result' );
is( $baskets[0]->basketno, $basket1->basketno, 'result is basket1' );

@baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo value for basket1',
        },
        {
            id    => $bar->id,
            value => 'bar value for basket2',
        },
    ]
)->as_list;

is( scalar @baskets, 0, 'search returns no result' );

@baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo',
        },
    ]
)->as_list;

is( scalar @baskets, 2, 'search returns two results' );

@baskets = Koha::Acquisition::Baskets->filter_by_additional_fields(
    [
        {
            id    => $foo->id,
            value => 'foo',
        },
        {
            id    => $foo->id,
            value => 'basket1',
        },
    ]
)->as_list;

is( scalar @baskets,       1,                  'search returns only one result' );
is( $baskets[0]->basketno, $basket1->basketno, 'result is basket1' );

$storage->txn_rollback;
