#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 14;
use C4::Context;
use C4::Acquisition qw( NewBasket GetOrders GetOrder TransferOrder SearchOrders ModReceiveOrder CancelReceipt );
use C4::Biblio;
use C4::Items;
use C4::Budgets qw( AddBudget GetBudget );
use Koha::Database;
use Koha::DateUtils;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use t::lib::TestBuilder;
use MARC::Record;
use String::Random qw(random_string);

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;

my $bookseller1 = Koha::Acquisition::Bookseller->new(
    {
        name => "my vendor 1",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
)->store;

my $basketno1 = C4::Acquisition::NewBasket(
    $bookseller1->id
);

my $bookseller2 = Koha::Acquisition::Bookseller->new(
    {
        name => "my vendor 2",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
)->store;

my $basketno2 = C4::Acquisition::NewBasket(
    $bookseller2->id
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_transferorder",
        budget_name => "budget_name_test_transferorder",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my $biblio = $builder->build_sample_biblio();
my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
my $biblionumber = $biblio->biblionumber;

my $order = Koha::Acquisition::Order->new(
    {
        basketno => $basketno1,
        quantity => 2,
        biblionumber => $biblionumber,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber = $order->ordernumber;
$order->add_item( $item_1->itemnumber );

# Begin tests
is(scalar GetOrders($basketno1), 1, "1 order in basket1");
($order) = GetOrders($basketno1);
$order = Koha::Acquisition::Orders->find($order->{ordernumber});
is($order->items->count, 1, "1 item in basket1's order");
is(scalar GetOrders($basketno2), 0, "0 order in basket2");

# Transfering order to basket2
my $newordernumber = TransferOrder($ordernumber, $basketno2);
is(scalar GetOrders($basketno1), 0, "0 order in basket1");
is(scalar GetOrders($basketno2), 1, "1 order in basket2");

# Determine if the transfer marked things cancelled properly.
is($order->orderstatus,'new','Before the transfer, the order status should be new');
$order = Koha::Acquisition::Orders->find($order->ordernumber);
is($order->orderstatus,'cancelled','After the transfer, the order status should be set to cancelled');

($order) = GetOrders($basketno2);
$order = Koha::Acquisition::Orders->find($order->{ordernumber});
is($order->items->count, 1, "1 item in basket2's order");

# Bug 11552
my $orders = SearchOrders({ ordernumber => $newordernumber });
is ( scalar( @$orders ), 1, 'SearchOrders returns 1 order with newordernumber' );
$orders = SearchOrders({ ordernumber => $ordernumber });
is ( scalar( @$orders ), 1, 'SearchOrders returns 1 order with [old]ordernumber' );
is ( $orders->[0]->{ordernumber}, $newordernumber, 'SearchOrders returns newordernumber if [old]ordernumber is given' );

my $neworder = Koha::Acquisition::Orders->find( $newordernumber )->unblessed;

ModReceiveOrder({
    biblionumber => $biblionumber,
    order       => $neworder,
    quantityreceived => 2, 
});
CancelReceipt( $newordernumber );
$order = GetOrder( $newordernumber );
is ( $order->{ordernumber}, $newordernumber, 'Regression test Bug 11549: After a transfer, receive and cancel the receive should be possible.' );
is ( $order->{basketno}, $basketno2, 'Regression test Bug 11549: The order still exist in the basket where the transfer has been done.');

subtest 'TransferOrder should copy additional fields' => sub {
    plan tests => 2;

    my $field = Koha::AdditionalField->new(
        {
            tablename => 'aqorders',
            name => random_string('c' x 100),
        }
    );
    $field->store()->discard_changes();
    my $order = Koha::Acquisition::Order->new(
        {
            basketno => $basketno1,
            quantity => 2,
            biblionumber => $biblionumber,
            budget_id => $budget->{budget_id},
        }
    )->store;
    $order->set_additional_fields(
        [
            {
                id => $field->id,
                value => 'additional field value',
            },
        ]
    );

    my $newordernumber = TransferOrder($order->ordernumber, $basketno2);
    my $neworder = Koha::Acquisition::Orders->find($newordernumber);
    my $field_values = $neworder->additional_field_values()->as_list;

    is(scalar @$field_values, 1, 'transfered order has one additional field value');
    is($field_values->[0]->value, 'additional field value', 'transfered order additional field has the correct value');
};

$schema->storage->txn_rollback();
