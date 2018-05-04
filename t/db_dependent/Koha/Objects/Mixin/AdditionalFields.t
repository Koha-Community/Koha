#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 10;

use Koha::Acquisition::Baskets; # Koha::Acquisition::Baskets uses the mixin
use Koha::AdditionalFields;
use Koha::AdditionalField;
use Koha::AdditionalFieldValue;
use Koha::Database;

use t::lib::TestBuilder;

my $storage = Koha::Database->new->schema->storage;
$storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $basket1 = $builder->build_object({
    class => 'Koha::Acquisition::Baskets',
});
my $basket2 = $builder->build_object({
    class => 'Koha::Acquisition::Baskets',
});

my $foo = Koha::AdditionalField->new({
    tablename => 'aqbasket',
    name => 'basket_foo',
})->store;
my $bar = Koha::AdditionalField->new({
    tablename => 'aqbasket',
    name => 'basket_bar',
})->store;

Koha::AdditionalFieldValue->new({
    field_id => $foo->id,
    record_id => $basket1->basketno,
    value => 'foo value for basket1',
})->store;
Koha::AdditionalFieldValue->new({
    field_id => $bar->id,
    record_id => $basket1->basketno,
    value => 'bar value for basket1',
})->store;
Koha::AdditionalFieldValue->new({
    field_id => $foo->id,
    record_id => $basket2->basketno,
    value => 'foo value for basket2',
})->store;
Koha::AdditionalFieldValue->new({
    field_id => $bar->id,
    record_id => $basket2->basketno,
    value => 'bar value for basket2',
})->store;

my @baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo value for basket1',
    },
]);

is(scalar @baskets, 1, 'search returns only one result');
is($baskets[0]->basketno, $basket1->basketno, 'result is basket1');

@baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo value for basket2',
    },
]);

is(scalar @baskets, 1, 'search returns only one result');
is($baskets[0]->basketno, $basket2->basketno, 'result is basket2');

@baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo value for basket1',
    },
    {
        id => $bar->id,
        value => 'bar value for basket1',
    },
]);

is(scalar @baskets, 1, 'search returns only one result');
is($baskets[0]->basketno, $basket1->basketno, 'result is basket1');

@baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo value for basket1',
    },
    {
        id => $bar->id,
        value => 'bar value for basket2',
    },
]);

is(scalar @baskets, 0, 'search returns no result');

@baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo',
    },
]);

is(scalar @baskets, 2, 'search returns two results');

@baskets = Koha::Acquisition::Baskets->search_additional_fields([
    {
        id => $foo->id,
        value => 'foo',
    },
    {
        id => $foo->id,
        value => 'basket1',
    },
]);

is(scalar @baskets, 1, 'search returns only one result');
is($baskets[0]->basketno, $basket1->basketno, 'result is basket1');

$storage->txn_rollback;
