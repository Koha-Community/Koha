#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 15;
use C4::Context;
use C4::Acquisition qw( NewBasket GetBasket SearchOrders AddInvoice ModReceiveOrder CancelReceipt );
use C4::Biblio      qw( AddBiblio );
use C4::Items;
use C4::Budgets;
use Koha::Acquisition::Orders;
use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

# Set up configuration data

my $branch      = $builder->build( { source => 'Branch' } );
my $bookseller  = $builder->build( { source => 'Aqbookseller' } );
my $budget      = $builder->build( { source => 'Aqbudget' } );
my $staffmember = $builder->build( { source => 'Borrower' } );
my $curcode     = $builder->build( { source => 'Currency' } )->{currencycode};

# Create baskets and orders

my $basketno = NewBasket(
    $bookseller->{id},
    $staffmember->{borrowernumber},
    'Standing order basket',    # basketname
    '',                         # basketnote
    '',                         # basketbooksellernote
    undef,                      # basketcontractnumber
    $branch->{branchcode},      # deliveryplace
    $branch->{branchcode},      # billingplace
    1                           # is_standing
);

my $nonstandingbasketno = NewBasket(
    $bookseller->{id},
    $staffmember->{borrowernumber},
    'Non-standing order basket',    # basketname
    '',                             # basketnote
    '',                             # basketbooksellernote
    undef,                          # basketcontractnumber
    $branch->{branchcode},          # deliveryplace
    $branch->{branchcode},          # billingplace
    0                               # is_standing
);

my $basket = GetBasket($basketno);

is( $basket->{is_standing}, 1, 'basket correctly created as standing order basket' );

my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( MARC::Record->new, '' );

my $ordernumber = Koha::Acquisition::Order->new(
    {
        basketno               => $basketno,
        biblionumber           => $biblionumber,
        budget_id              => $budget->{budget_id},
        currency               => $curcode,
        quantity               => 0,
        rrp                    => 42,
        rrp_tax_included       => 42,
        rrp_tax_excluded       => 42,
        ecost                  => 22,
        ecost_tax_included     => 22,
        ecost_tax_excluded     => 22,
        unitprice              => 12,
        unitprice_tax_included => 12,
        unitprice_tax_excluded => 12,
        tax_rate_on_ordering   => 0,
        tax_rate_on_receiving  => 0,
    }
)->store->ordernumber;

isnt( $ordernumber, undef, 'standing order successfully created' );

my $search_orders = SearchOrders(
    {
        basketno => $basketno,
        pending  => 1,
        ordered  => 1,
    }
);

ok(
    scalar @$search_orders == 1 && $search_orders->[0]->{ordernumber} == $ordernumber,
    'standing order counts as a pending/ordered order'
);

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $bookseller->{id},
    unknown       => "unknown"
);

my $order = Koha::Acquisition::Orders->find($ordernumber);

my ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        order            => $order->unblessed,
        quantityreceived => 2,
        invoiceid        => $invoiceid,
    }
);

isnt( $ordernumber, $new_ordernumber, "standing order split on receive" );

#order has been updated, refetch
$order = Koha::Acquisition::Orders->find($ordernumber);
my $neworder = Koha::Acquisition::Orders->find($new_ordernumber);

is( $order->orderstatus,      'partial', 'original order set to partially received' );
is( $order->quantity,         1,         'original order quantity unchanged' );
is( $order->quantityreceived, 0,         'original order has no received items' );
isnt( $order->unitprice, 12, 'original order does not get cost' );
is( $neworder->orderstatus,      'complete', 'new order set to complete' );
is( $neworder->quantityreceived, 2,          'new order has received items' );
cmp_ok( $neworder->unitprice, '==', 12, 'new order does get cost' );

$search_orders = SearchOrders(
    {
        basketno => $basketno,
        pending  => 1,
        ordered  => 1,
    }
);

is( scalar @$search_orders,             1,            'only one pending order after receive' );
is( $search_orders->[0]->{ordernumber}, $ordernumber, 'original order is only pending order' );

CancelReceipt($new_ordernumber);
$order = Koha::Acquisition::Orders->find($ordernumber);
is( $order->quantity, 1, 'CancelReceipt should not have increased the quantity if order is standing' );

$schema->storage->txn_rollback();
