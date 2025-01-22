#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 45;
use C4::Context;
use Koha::Database;
use Koha::Acquisition::Bookseller;
use Koha::Acquisition::Order;
use t::lib::TestBuilder;
use t::lib::Mocks;

# Start transaction
my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;

my $bookseller_inc_tax = Koha::Acquisition::Bookseller->new(
    {
        name          => "Tax included",
        address1      => "bookseller's address",
        phone         => "0123456",
        active        => 1,
        listincgst    => 1,
        invoiceincgst => 1,
    }
)->store;

my $bookseller_exc_tax = Koha::Acquisition::Bookseller->new(
    {
        name          => "Tax excluded",
        address1      => "bookseller's address",
        phone         => "0123456",
        active        => 1,
        listincgst    => 0,
        invoiceincgst => 0,
    }
)->store;

my $basket_exc_tax = Koha::Acquisition::Basket->new(
    {
        basketname   => 'Basket tax excluded',
        booksellerid => $bookseller_exc_tax->id,
    }
)->store;

my $order_exc_tax = Koha::Acquisition::Order->new(
    {
        tax_rate_on_ordering  => .1965,
        tax_rate_on_receiving => .1965,
        discount              => .42,
        rrp                   => 16.99,
        unitprice             => "0.00",
        quantity              => 8,
        basketno              => $basket_exc_tax->basketno,
    }
);

#Vendor prices exclude tax, no rounding, ordering
t::lib::Mocks::mock_preference( 'OrderPriceRounding', '' );
$order_exc_tax->populate_with_prices_for_ordering();

is( $order_exc_tax->rrp_tax_excluded + 0, 16.99, "Ordering tax excluded, no round: rrp tax excluded is rrp" );
is(
    $order_exc_tax->rrp_tax_included + 0, 20.328535,
    "Ordering tax excluded, no round: rrp tax included is rr tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->ecost_tax_excluded + 0, 9.8542,
    "Ordering tax excluded, no round: ecost tax excluded is rrp * ( 1 - discount )"
);
is(
    $order_exc_tax->ecost_tax_included + 0, 11.7905503,
    "Ordering tax excluded, no round: ecost tax included is ecost tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->tax_value_on_ordering + 0, 15.4908024,
    "Ordering tax excluded, no round: tax value on ordering is quantity * ecost_tax_excluded * tax rate on ordering if no unitprice"
);

$order_exc_tax->unitprice(9.85);

$order_exc_tax->populate_with_prices_for_ordering();

is( $order_exc_tax->unitprice_tax_excluded + 0, 9.85, "Ordering tax excluded, no round: rrp tax excluded is rrp" );
is(
    $order_exc_tax->unitprice_tax_included + 0, 11.785525,
    "Ordering tax excluded, no round: rrp tax included is rr tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->tax_value_on_ordering + 0, 15.4842,
    "Ordering tax excluded, no round: tax value on ordering is quantity * unitprice_tax_excluded * tax rate on ordering if unitprice"
);

#Vendor prices exclude tax, no rounding, receiving
$order_exc_tax->populate_with_prices_for_receiving();

is(
    $order_exc_tax->unitprice + 0, 9.8542,
    "Receiving tax excluded, no round, rounded ecost tax excluded = rounded unitprice : unitprice is ecost tax excluded"
);
is(
    $order_exc_tax->unitprice_tax_excluded + 0, 9.8542,
    "Receiving tax excluded, no round, rounded ecost tax excluded = rounded unitprice : unitprice tax excluded is ecost tax excluded"
);
is(
    $order_exc_tax->unitprice_tax_included + 0, 11.7905503,
    "Receiving tax excluded, no round: unitprice tax included is unitprice tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->tax_value_on_receiving + 0, 15.4908024,
    "Receiving tax excluded, no round: tax value on receiving is quantity * unitprice_tax_excluded * tax rate on receiving"
);

$order_exc_tax->unitprice(9.85);

#populate order with prices updates the passed in order hashref
#we need to reset after additional tests and changes

#Vendor prices exclude tax, rounding to nearest cent, ordering
t::lib::Mocks::mock_preference( 'OrderPriceRounding', 'nearest_cent' );
$order_exc_tax->populate_with_prices_for_ordering();

is(
    $order_exc_tax->unitprice_tax_excluded + 0, 9.85,
    "Ordering tax excluded, round: unitprice tax excluded is unitprice"
);
is(
    $order_exc_tax->unitprice_tax_included + 0, 11.785525,
    "Ordering tax excluded, round: unitprice tax included is unitprice tax excluded * (1 + tax rate on ordering)"
);
is( $order_exc_tax->rrp_tax_excluded + 0, 16.99, "Ordering tax excluded, round: rrp tax excluded is rrp" );
is(
    $order_exc_tax->rrp_tax_included + 0, 20.328535,
    "Ordering tax excluded, round: rrp tax included is rr tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->ecost_tax_excluded + 0, 9.8542,
    "Ordering tax excluded, round: ecost tax excluded is rrp * ( 1 - discount )"
);
is(
    $order_exc_tax->ecost_tax_included + 0, 11.7905503,
    "Ordering tax excluded, round: ecost tax included is ecost tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->tax_value_on_ordering + 0, 15.4842,
    "Ordering tax excluded, round: tax value on ordering is quantity * ecost_tax_excluded * tax rate on ordering"
);

#Vendor prices exclude tax, no rounding, receiving
$order_exc_tax->populate_with_prices_for_receiving();

is(
    $order_exc_tax->unitprice_tax_excluded + 0, 9.8542,
    "Receiving tax excluded, round, rounded ecost tax excluded = rounded unitprice : unitprice tax excluded is ecost tax excluded"
);
is(
    $order_exc_tax->unitprice_tax_included + 0, 11.7905503,
    "Receiving tax excluded, round: unitprice tax included is unitprice tax excluded * (1 + tax rate on ordering)"
);
is(
    $order_exc_tax->tax_value_on_receiving + 0, 15.4842,
    "Receiving tax excluded, round: tax value on receiving is quantity * unitprice_tax_excluded * tax rate on receiving"
);

my $basket_inc_tax = Koha::Acquisition::Basket->new(
    {
        basketname   => 'Basket tax included',
        booksellerid => $bookseller_inc_tax->id,
    }
)->store;

my $order_inc_tax = Koha::Acquisition::Order->new(
    {
        tax_rate_on_ordering  => .1965,
        tax_rate_on_receiving => .1965,
        discount              => .42,
        rrp                   => 20.33,
        unitprice             => 0.00,
        quantity              => 8,
        basketno              => $basket_inc_tax->basketno,
    }
);

#Vendor prices include tax, no rounding, ordering
t::lib::Mocks::mock_preference( 'OrderPriceRounding', '' );
$order_inc_tax->populate_with_prices_for_ordering();

is( $order_inc_tax->rrp_tax_included + 0, 20.33, "Ordering tax included, no round: rrp tax included is rrp" );
is(
    $order_inc_tax->rrp_tax_excluded + 0, 16.9912244045132,
    "Ordering tax included, no round: rrp tax excluded is rrp tax included / (1 + tax rate on ordering)"
);
is(
    $order_inc_tax->ecost_tax_included + 0, 11.7914,
    "Ordering tax included, no round: ecost tax included is rrp tax included * (1 - discount)"
);
is(
    $order_inc_tax->ecost_tax_excluded + 0, 9.85491015461764,
    "Ordering tax included, no round: ecost tax excluded is rrp tax excluded * ( 1 - discount )"
);
is(
    $order_inc_tax->tax_value_on_ordering + 0, 15.4919187630589,
    "Ordering tax included, no round: tax value on ordering is ( ecost tax included - ecost tax excluded ) * quantity if no unitprice"
);

$order_inc_tax->unitprice(11.79);
$order_inc_tax->populate_with_prices_for_ordering();

is(
    $order_inc_tax->unitprice_tax_included + 0, 11.79,
    "Ordering tax included, no round: unitprice tax included is unitprice"
);
is(
    $order_inc_tax->unitprice_tax_excluded + 0, 9.85374007521939,
    "Ordering tax included, no round: unitprice tax excluded is unitprice tax included / (1 + tax_rate_on_ordering "
);
is(
    $order_inc_tax->tax_value_on_ordering + 0, 15.4900793982449,
    "Ordering tax included, no round: tax value on ordering is ( unitprice tax included - unitprice tax excluded ) * quantity if unitprice"
);

#Vendor prices include tax, no rounding, receiving
$order_inc_tax->populate_with_prices_for_receiving();

is(
    $order_inc_tax->unitprice + 0, 11.7914,
    "Receiving tax included, no round, rounded ecost tax excluded = rounded unitprice : unitprice is ecost tax excluded"
);
is(
    $order_inc_tax->unitprice_tax_included + 0, 11.7914,
    "Receiving tax included, no round: unitprice tax included is unitprice"
);
is(
    $order_inc_tax->unitprice_tax_excluded + 0, 9.85491015461764,
    "Receiving tax included, no round: unitprice tax excluded is unitprice tax included / (1 + tax rate on receiving)"
);
is(
    $order_inc_tax->tax_value_on_receiving + 0, 15.4919187630589,
    "Receiving tax included, no round: tax value on receiving is quantity * unitprice_tax_excluded * tax rate on receiving"
);

#Vendor prices include tax, rounding to nearest cent, ordering
t::lib::Mocks::mock_preference( 'OrderPriceRounding', 'nearest_cent' );
$order_inc_tax->unitprice(11.79);
$order_inc_tax->populate_with_prices_for_ordering();

is(
    $order_inc_tax->unitprice_tax_included + 0, 11.79,
    "Ordering tax included, round: unitprice tax included is unitprice"
);
is(
    $order_inc_tax->unitprice_tax_excluded + 0, 9.85374007521939,
    "Ordering tax included, round: unitprice tax excluded is unitprice tax included / (1 + tax_rate_on_ordering "
);
is( $order_inc_tax->rrp_tax_included + 0, 20.33, "Ordering tax included, round: rrp tax included is rrp" );
is(
    $order_inc_tax->rrp_tax_excluded + 0, 16.9912244045132,
    "Ordering tax included, round: rrp tax excluded is rounded rrp tax included * (1 + tax rate on ordering)"
);
is(
    $order_inc_tax->ecost_tax_included + 0, 11.7914,
    "Ordering tax included, round: ecost tax included is rounded rrp * ( 1 - discount )"
);
is(
    $order_inc_tax->ecost_tax_excluded + 0, 9.85491015461764,
    "Ordering tax included, round: ecost tax excluded is rounded ecost tax excluded * (1 - discount)"
);
is(
    $order_inc_tax->tax_value_on_ordering + 0, 15.52,
    "Ordering tax included, round: tax value on ordering is (ecost_tax_included - ecost_tax_excluded) * quantity"
);

#Vendor prices include tax, no rounding, receiving
$order_inc_tax->populate_with_prices_for_receiving();

is(
    $order_inc_tax->unitprice_tax_included + 0, 11.7914,
    "Receiving tax included, round: rounded ecost tax included = rounded unitprice : unitprice tax excluded is ecost tax included"
);
is(
    $order_inc_tax->unitprice_tax_excluded + 0, 9.85491015461764,
    "Receiving tax included, round: unitprice tax excluded is unitprice tax included / (1 + tax rate on ordering)"
);
is(
    $order_inc_tax->tax_value_on_receiving + 0, 15.4842,
    "Receiving tax included, round: tax value on receiving is quantity * (rounded unitprice_tax_excluded) * tax rate on receiving"
);

$schema->storage->txn_rollback();
