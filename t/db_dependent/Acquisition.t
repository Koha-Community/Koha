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

use POSIX qw(strftime);

use Test::More tests => 72;
use t::lib::Mocks;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string output_pref);
use Koha::Acquisition::Basket;

use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'MARC21' );

BEGIN {
    use_ok('C4::Acquisition', qw( NewBasket GetBasket AddInvoice GetInvoice GetInvoices ModReceiveOrder SearchOrders GetOrder GetHistory ModOrder get_rounding_sql get_rounded_price ReopenBasket ModBasket ModBasketHeader ModBasketUsers ));
    use_ok('C4::Biblio', qw( AddBiblio GetMarcSubfieldStructure ));
    use_ok('C4::Budgets', qw( AddBudgetPeriod AddBudget GetBudget GetBudgetByOrderNumber GetBudgetsReport GetBudgets GetBudgetReport ));
    use_ok('Koha::Acquisition::Orders');
    use_ok('Koha::Acquisition::Booksellers');
    use_ok('t::lib::TestBuilder');
}

# Sub used for testing C4::Acquisition subs returning order(s):
#    GetOrdersByStatus, GetOrders, GetDeletedOrders, GetOrder etc.
# (\@test_missing_fields,\@test_extra_fields,\@test_different_fields,$test_nbr_fields) =
#  _check_fields_of_order ($exp_fields, $original_order_content, $order_to_check);
# params :
# $exp_fields             : arrayref whose elements are the keys we expect to find
# $original_order_content : hashref whose 2 keys str and num contains hashrefs
#                           containing content fields of the order created with Koha::Acquisition::Order
# $order_to_check         : hashref whose keys/values are the content of an order
#                           returned by the C4::Acquisition sub we are testing
# returns :
# \@test_missing_fields   : arrayref void if ok ; otherwise contains the list of
#                           fields missing in $order_to_check
# \@test_extra_fields     : arrayref void if ok ; otherwise contains the list of
#                           fields unexpected in $order_to_check
# \@test_different_fields : arrayref void if ok ; otherwise contains the list of
#                           fields which value is not the same in between $order_to_check and
# $test_nbr_fields        : contains the number of fields of $order_to_check

sub _check_fields_of_order {
    my ( $exp_fields, $original_order_content, $order_to_check ) = @_;
    my @test_missing_fields   = ();
    my @test_extra_fields     = ();
    my @test_different_fields = ();
    my $test_nbr_fields       = scalar( keys %$order_to_check );
    foreach my $field (@$exp_fields) {
        push @test_missing_fields, $field
          unless exists( $order_to_check->{$field} );
    }
    foreach my $field ( keys %$order_to_check ) {
        push @test_extra_fields, $field
          unless grep ( /^$field$/, @$exp_fields );
    }
    foreach my $field ( keys %{ $original_order_content->{str} } ) {
        push @test_different_fields, $field
          unless ( !exists $order_to_check->{$field} )
          or ( $original_order_content->{str}->{$field} eq
            $order_to_check->{$field} );
    }
    foreach my $field ( keys %{ $original_order_content->{num} } ) {
        push @test_different_fields, $field
          unless ( !exists $order_to_check->{$field} )
          or ( $original_order_content->{num}->{$field} ==
            $order_to_check->{$field} );
    }
    return (
        \@test_missing_fields,   \@test_extra_fields,
        \@test_different_fields, $test_nbr_fields
    );
}

# Sub used for testing C4::Acquisition subs returning several orders
# (\@test_missing_fields,\@test_extra_fields,\@test_different_fields,\@test_nbr_fields) =
#   _check_fields_of_orders ($exp_fields, $original_orders_content, $orders_to_check)
sub _check_fields_of_orders {
    my ( $exp_fields, $original_orders_content, $orders_to_check ) = @_;
    my @test_missing_fields   = ();
    my @test_extra_fields     = ();
    my @test_different_fields = ();
    my @test_nbr_fields       = ();
    foreach my $order_to_check (@$orders_to_check) {
        my $original_order_content =
          ( grep { $_->{str}->{ordernumber} eq $order_to_check->{ordernumber} }
              @$original_orders_content )[0];
        my (
            $t_missing_fields,   $t_extra_fields,
            $t_different_fields, $t_nbr_fields
          )
          = _check_fields_of_order( $exp_fields, $original_order_content,
            $order_to_check );
        push @test_missing_fields,   @$t_missing_fields;
        push @test_extra_fields,     @$t_extra_fields;
        push @test_different_fields, @$t_different_fields;
        push @test_nbr_fields,       $t_nbr_fields;
    }
    @test_missing_fields = keys %{ { map { $_ => 1 } @test_missing_fields } };
    @test_extra_fields   = keys %{ { map { $_ => 1 } @test_extra_fields } };
    @test_different_fields =
      keys %{ { map { $_ => 1 } @test_different_fields } };
    return (
        \@test_missing_fields,   \@test_extra_fields,
        \@test_different_fields, \@test_nbr_fields
    );
}


my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

# Creating some orders
my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name         => "my vendor",
        address1     => "bookseller's address",
        phone        => "0123456",
        active       => 1,
        deliverytime => 5,
    }
)->store;
my $booksellerid = $bookseller->id;

my $booksellerinfo = Koha::Acquisition::Booksellers->find( $booksellerid );
is( $booksellerinfo->deliverytime,
    5, 'set deliverytime when creating vendor (Bug 10556)' );

my ( $basket, $basketno );
ok(
    $basketno = NewBasket( $booksellerid, 1 ),
    "NewBasket(  $booksellerid , 1  ) returns $basketno"
);
ok( $basket = GetBasket($basketno), "GetBasket($basketno) returns $basket" );

my $bpid=AddBudgetPeriod({
        budget_period_startdate => '2008-01-01'
        , budget_period_enddate => '2008-12-31'
        , budget_period_active  => 1
        , budget_period_description    => "MAPERI"
});

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_1",
        budget_name => "budget_name_test_1",
        budget_period_id => $bpid,
    }
);
my $budget = C4::Budgets::GetBudget($budgetid);

my @ordernumbers;
my ( $biblionumber1, $biblioitemnumber1 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber2, $biblioitemnumber2 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber3, $biblioitemnumber3 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber4, $biblioitemnumber4 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber5, $biblioitemnumber5 ) = AddBiblio( MARC::Record->new, '' );



# Prepare 6 orders, and make distinction beween fields to be tested with eq and with ==
# Ex : a price of 50.1 will be stored internally as 5.100000

my @order_content = (
    {
        str => {
            basketno       => $basketno,
            biblionumber   => $biblionumber1,
            budget_id      => $budget->{budget_id},
            uncertainprice => 0,
            order_internalnote => "internal note foo",
            order_vendornote   => "vendor note bar",
            ordernumber => '',
        },
        num => {
            quantity  => 24,
            listprice => 50.121111,
            ecost     => 38.15,
            rrp       => 40.15,
            discount  => 5.1111,
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber2,
            budget_id    => $budget->{budget_id}
        },
        num => { quantity => 42 }
    },
    {
        str => {
            basketno       => $basketno,
            biblionumber   => $biblionumber2,
            budget_id      => $budget->{budget_id},
            uncertainprice => 0,
            order_internalnote => "internal note foo",
            order_vendornote   => "vendor note bar"
        },
        num => {
            quantity  => 4,
            ecost     => 42.1,
            rrp       => 42.1,
            listprice => 10.1,
            ecost     => 38.1,
            rrp       => 11.0,
            discount  => 5.1,
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber3,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity       => 4,
            ecost          => 40,
            rrp            => 42,
            listprice      => 10,
            ecost          => 38.15,
            rrp            => 11.00,
            discount       => 0,
            uncertainprice => 0,
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber4,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note bar",
            order_vendornote   => "vendor note foo"
        },
        num => {
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber5,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
        }
    }
);

# Create 6 orders in database
for ( 0 .. 5 ) {
    my %ocontent;
    @ocontent{ keys %{ $order_content[$_]->{num} } } =
      values %{ $order_content[$_]->{num} };
    @ocontent{ keys %{ $order_content[$_]->{str} } } =
      values %{ $order_content[$_]->{str} };
    $ordernumbers[$_] = Koha::Acquisition::Order->new( \%ocontent )->store->ordernumber;
    $order_content[$_]->{str}->{ordernumber} = $ordernumbers[$_];
}

Koha::Acquisition::Orders->find($ordernumbers[3])->cancel;

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $booksellerid,
    unknown       => "unknown"
);

my $invoice = GetInvoice( $invoiceid );

my $reception_date = output_pref(
    {
            dt => dt_from_string->add( days => 1 ),
            dateformat => 'iso',
            dateonly => 1,
    }
);
my ($datereceived, $new_ordernumber) = ModReceiveOrder(
    {
        biblionumber      => $biblionumber4,
        order             => Koha::Acquisition::Orders->find( $ordernumbers[4] )->unblessed,
        quantityreceived  => 1,
        invoice           => $invoice,
        budget_id         => $order_content[4]->{str}->{budget_id},
        datereceived      => $reception_date,
    }
);

is(
    output_pref(
        {
            dt         => dt_from_string($datereceived),
            dateformat => 'iso',
            dateonly   => 1
        }
    ),
    $reception_date,
    'ModReceiveOrder sets the passed date'
);

my $search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno
});
isa_ok( $search_orders, 'ARRAY' );
ok(
    (
        ( scalar @$search_orders == 5 )
          and !grep ( $_->{ordernumber} eq $ordernumbers[3], @$search_orders )
    ),
    "SearchOrders only gets non-cancelled orders"
);

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1
});
ok(
    (
        ( scalar @$search_orders == 4 ) and !grep ( (
                     ( $_->{ordernumber} eq $ordernumbers[3] )
                  or ( $_->{ordernumber} eq $ordernumbers[4] )
            ),
            @$search_orders )
    ),
    "SearchOrders with pending params gets only pending orders (bug 10723)"
);

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1,
    ordered      => 1,
});
is( scalar (@$search_orders), 0, "SearchOrders with pending and ordered params gets only pending ordered orders (bug 11170)" );

$search_orders = SearchOrders({
    ordernumber => $ordernumbers[4]
});
is( scalar (@$search_orders), 1, "SearchOrders takes into account the ordernumber filter" );

$search_orders = SearchOrders({
    biblionumber => $biblionumber4
});
is( scalar (@$search_orders), 1, "SearchOrders takes into account the biblionumber filter" );

$search_orders = SearchOrders({
    biblionumber => $biblionumber4,
    pending      => 1
});
is( scalar (@$search_orders), 0, "SearchOrders takes into account the biblionumber and pending filters" );

#
# Test GetBudgetByOrderNumber
#
ok( GetBudgetByOrderNumber( $ordernumbers[0] )->{'budget_id'} eq $budgetid,
    "GetBudgetByOrderNumber returns expected budget" );

my $lateorders = Koha::Acquisition::Orders->filter_by_lates({ delay => 0 });
is( $lateorders->search({ 'me.basketno' => $basketno })->count,
    0, "GetLateOrders does not get orders from opened baskets" );
Koha::Acquisition::Baskets->find($basketno)->close;
$lateorders = Koha::Acquisition::Orders->filter_by_lates({ delay => 0 });
isnt( $lateorders->search({ 'me.basketno' => $basketno })->count,
    0, "GetLateOrders gets orders from closed baskets" );
is( $lateorders->search({ ordernumber => $ordernumbers[3] })->count, 0,
    "GetLateOrders does not get cancelled orders" );
is( $lateorders->search({ ordernumber => $ordernumbers[4] })->count, 0,
    "GetLateOrders does not get received orders" );

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1,
    ordered      => 1,
});
is( scalar (@$search_orders), 4, "SearchOrders with pending and ordered params gets only pending ordered orders. After closing the basket, orders are marked as 'ordered' (bug 11170)" );

#
# Test AddClaim
#

my $order = $lateorders->next;
$order->claim();
is(
    output_pref({ str => $order->claimed_date, dateformat => 'iso', dateonly => 1 }),
    strftime( "%Y-%m-%d", localtime(time) ),
    "Koha::Acquisition::Order->claim: Check claimed_date"
);

my $order2 = Koha::Acquisition::Orders->find( $ordernumbers[1] )->unblessed;
$order2->{order_internalnote} = "my notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order2,
        quantityreceived => 2,
        invoice          => $invoice,
    }
);
$order2 = GetOrder( $ordernumbers[1] );
is( $order2->{'quantityreceived'},
    0, 'Splitting up order did not receive any on original order' );
is( $order2->{'quantity'}, 40, '40 items on original order' );
is( $order2->{'budget_id'}, $budgetid,
    'Budget on original order is unchanged' );
is( $order2->{order_internalnote}, "my notes",
    'ModReceiveOrder and GetOrder deal with internal notes' );
my $order1 = GetOrder( $ordernumbers[0] );
is(
    $order1->{order_internalnote},
    "internal note foo",
    "ModReceiveOrder only changes the supplied orders internal notes"
);

my $neworder = GetOrder($new_ordernumber);
is( $neworder->{'quantity'}, 2, '2 items on new order' );
is( $neworder->{'quantityreceived'},
    2, 'Splitting up order received items on new order' );
is( $neworder->{'budget_id'}, $budgetid, 'Budget on new order is unchanged' );

is( $neworder->{ordernumber}, $new_ordernumber, 'Split: test ordernumber' );
is( $neworder->{parent_ordernumber}, $ordernumbers[1], 'Split: test parent_ordernumber' );

my $orders = GetHistory( ordernumber => $ordernumbers[1] );
is( scalar( @$orders ), 1, 'GetHistory with a given ordernumber returns 1 order' );
$orders = GetHistory( ordernumber => $ordernumbers[1], search_children_too => 1 );
is( scalar( @$orders ), 2, 'GetHistory with a given ordernumber and search_children_too set returns 2 orders' );
$orders = GetHistory( ordernumbers => [$ordernumbers[1]] );
is( scalar( @$orders ), 1, 'GetHistory with a given ordernumbers returns 1 order' );
$orders = GetHistory( ordernumbers => \@ordernumbers );
is( scalar( @$orders ), scalar( @ordernumbers ) - 1, 'GetHistory with a list of ordernumbers returns N-1 orders (was has been deleted [3])' );

$orders = GetHistory( internalnote => 'internal note foo' );
is( scalar( @$orders ), 2, 'GetHistory returns correctly a search for internalnote' );
$orders = GetHistory( vendornote => 'vendor note bar' );
is( scalar( @$orders ), 2, 'GetHistory returns correctly a search for vendornote' );
$orders = GetHistory( internalnote => 'internal note bar' );
is( scalar( @$orders ), 1, 'GetHistory returns correctly a search for internalnote' );
$orders = GetHistory( vendornote => 'vendor note foo' );
is( scalar( @$orders ), 1, 'GetHistory returns correctly a search for vendornote' );

my $budgetid2 = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_modrecv",
        budget_name => "budget_name_test_modrecv",
    }
);

my $order3 = Koha::Acquisition::Orders->find( $ordernumbers[2] )->unblessed;
$order3->{order_internalnote} = "my other notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order3,
        quantityreceived => 2,
        invoice          => $invoice,
        budget_id        => $budgetid2,
    }
);

$order3 = GetOrder( $ordernumbers[2] );
is( $order3->{'quantityreceived'},
    0, 'Splitting up order did not receive any on original order' );
is( $order3->{'quantity'}, 2, '2 items on original order' );
is( $order3->{'budget_id'}, $budgetid,
    'Budget on original order is unchanged' );
is( $order3->{order_internalnote}, "my other notes",
    'ModReceiveOrder and GetOrder deal with notes' );

$neworder = GetOrder($new_ordernumber);
is( $neworder->{'quantity'}, 2, '2 items on new order' );
is( $neworder->{'quantityreceived'},
    2, 'Splitting up order received items on new order' );
is( $neworder->{'budget_id'}, $budgetid2, 'Budget on new order is changed' );

$order3 = Koha::Acquisition::Orders->find( $ordernumbers[2] )->unblessed;
$order3->{order_internalnote} = "my third notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order3,
        quantityreceived => 2,
        invoice          => $invoice,
        budget_id        => $budgetid2,
    }
);

$order3 = GetOrder( $ordernumbers[2] );
is( $order3->{'quantityreceived'}, 2,          'Order not split up' );
is( $order3->{'quantity'},         2,          '2 items on order' );
is( $order3->{'budget_id'},        $budgetid2, 'Budget has changed' );
is( $order3->{order_internalnote}, "my third notes", 'ModReceiveOrder and GetOrder deal with notes' );

my $nonexistent_order = GetOrder();
is( $nonexistent_order, undef, 'GetOrder returns undef if no ordernumber is given' );
$nonexistent_order = GetOrder( 424242424242 );
is( $nonexistent_order, undef, 'GetOrder returns undef if a nonexistent ordernumber is given' );

subtest 'ModOrder' => sub {
    plan tests => 1;
    ModOrder( { ordernumber => $order1->{ordernumber}, unitprice => 42 } );
    my $order = GetOrder( $order1->{ordernumber} );
    is( int($order->{unitprice}), 42, 'ModOrder should work even if biblionumber if not passed');
};

# Budget reports
my $all_count = scalar GetBudgetsReport();
ok($all_count >= 1, "GetBudgetReport OK");

my $active_count = scalar GetBudgetsReport(1);
ok($active_count >= 1 , "GetBudgetsReport(1) OK");

is($all_count, scalar GetBudgetsReport(), "GetBudgetReport returns inactive budget period acquisitions.");
ok($active_count >= scalar GetBudgetsReport(1), "GetBudgetReport doesn't return inactive budget period acquisitions.");

# "Flavoured" tests (tests that required a run for each marc flavour)
# Tests should be added to the run_flavoured_tests sub below
my $biblio_module = Test::MockModule->new('C4::Biblio');
$biblio_module->mock(
    'GetMarcSubfieldStructure',
    sub {
        my ($self) = shift;

        my ( $title_field,            $title_subfield )            = get_title_field();
        my ( $isbn_field,             $isbn_subfield )             = get_isbn_field();
        my ( $issn_field,             $issn_subfield )             = get_issn_field();
        my ( $biblionumber_field,     $biblionumber_subfield )     = ( '999', 'c' );
        my ( $biblioitemnumber_field, $biblioitemnumber_subfield ) = ( '999', '9' );
        my ( $itemnumber_field,       $itemnumber_subfield )       = get_itemnumber_field();

        return {
            'biblio.title'                 => [ { tagfield => $title_field,            tagsubfield => $title_subfield } ],
            'biblio.biblionumber'          => [ { tagfield => $biblionumber_field,     tagsubfield => $biblionumber_subfield } ],
            'biblioitems.isbn'             => [ { tagfield => $isbn_field,             tagsubfield => $isbn_subfield } ],
            'biblioitems.issn'             => [ { tagfield => $issn_field,             tagsubfield => $issn_subfield } ],
            'biblioitems.biblioitemnumber' => [ { tagfield => $biblioitemnumber_field, tagsubfield => $biblioitemnumber_subfield } ],
            'items.itemnumber'             => [ { tagfield => $itemnumber_subfield,    tagsubfield => $itemnumber_subfield } ],
        };
      }
);

sub run_flavoured_tests {
    my $marcflavour = shift;
    t::lib::Mocks::mock_preference('marcflavour', $marcflavour);

    #
    # Test SearchWithISBNVariations syspref
    #
    my $marc_record = MARC::Record->new;
    $marc_record->append_fields( create_isbn_field( '9780136019701', $marcflavour ) );
    my ( $biblionumber6, $biblioitemnumber6 ) = AddBiblio( $marc_record, '' );

    # Create order
    my $ordernumber = Koha::Acquisition::Order->new( {
            basketno     => $basketno,
            biblionumber => $biblionumber6,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note",
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
    } )->store->ordernumber;

    t::lib::Mocks::mock_preference('SearchWithISBNVariations', 0);
    $orders = GetHistory( isbn => '0136019706' );
    is( scalar(@$orders), 0, "GetHistory searches correctly by ISBN" );

    t::lib::Mocks::mock_preference('SearchWithISBNVariations', 1);
    $orders = GetHistory( isbn => '0136019706' );
    is( scalar(@$orders), 1, "GetHistory searches correctly by ISBN" );

    Koha::Acquisition::Orders->find($ordernumber)->cancel;

    my $marc_record_issn = MARC::Record->new;
    $marc_record_issn->append_fields( create_issn_field( '2434561X', $marcflavour ) );
    my ( $biblionumber6_issn, undef ) = AddBiblio( $marc_record_issn, '' );

    my $orders_issn = GetHistory( issn => '2434561X' );
    is( scalar(@$orders_issn), 0, "Precheck that ISSN shouldn't be in database" );

    # Create order
    my $ordernumber_issn = Koha::Acquisition::Order->new( {
            basketno     => $basketno,
            biblionumber => $biblionumber6_issn,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note",
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
    } )->store->ordernumber;

    t::lib::Mocks::mock_preference('SearchWithISSNVariations', 0);
    $orders_issn = GetHistory( issn => '2434-561X' );
    is( scalar(@$orders_issn), 0, "GetHistory searches correctly by ISSN" );

    t::lib::Mocks::mock_preference('SearchWithISSNVariations', 1);
    $orders_issn = GetHistory( issn => '2434-561X' );
    is( scalar(@$orders_issn), 1, "GetHistory searches correctly by ISSN" );

    Koha::Acquisition::Orders->find($ordernumber_issn)->cancel;
}

# Test GetHistory() with and without SearchWithISBNVariations or SearchWithISSNVariations
# The ISBN passed as a param is the ISBN-10 version of the 13-digit ISBN in the sample record declared in $marcxml

# Do "flavoured" tests
subtest 'MARC21' => sub {
    plan tests => 5;
    run_flavoured_tests('MARC21');
};

subtest 'UNIMARC' => sub {
    plan tests => 5;
    run_flavoured_tests('UNIMARC');
};

### Functions required for "flavoured" tests
sub get_title_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'a' ) : ( '245', 'a' );
}

sub get_isbn_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '010', 'a' ) : ( '020', 'a' );
}

sub get_issn_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '011', 'a' ) : ( '022', 'a' );
}

sub get_itemnumber_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '995', '9' ) : ( '952', '9' );
}

sub create_isbn_field {
    my ( $isbn, $marcflavour ) = @_;

    my ( $isbn_field, $isbn_subfield ) = get_isbn_field();
    my $field = MARC::Field->new( $isbn_field, '', '', $isbn_subfield => $isbn );

    # Add the price subfield
    my $price_subfield = ( $marcflavour eq 'UNIMARC' ) ? 'd' : 'c';
    $field->add_subfields( $price_subfield => '$100' );

    return $field;
}

sub create_issn_field {
    my ( $issn, $marcflavour ) = @_;

    my ( $issn_field, $issn_subfield ) = get_issn_field();
    my $field = MARC::Field->new( $issn_field, '', '', $issn_subfield => $issn );

    return $field;
}

subtest 'ModReceiveOrder replacementprice tests' => sub {
    plan tests => 2;
    #Let's build an order, we need a couple things though
    my $builder = t::lib::TestBuilder->new;
    my $order_biblio = $builder->build_sample_biblio;
    my $order_basket = $builder->build({ source => 'Aqbasket', value => { is_standing => 0 } });
    my $order_invoice = $builder->build({ source => 'Aqinvoice'});
    my $order_currency = $builder->build({ source => 'Currency', value => { active => 1, archived => 0, symbol => 'F', rate => 2, isocode => undef, currency => 'FOO' }  });
    my $order_vendor = $builder->build({ source => 'Aqbookseller',value => { listincgst => 0, listprice => $order_currency->{currency}, invoiceprice => $order_currency->{currency} } });
    my $orderinfo ={
        basketno => $order_basket->{basketno},
        rrp => 19.99,
        replacementprice => undef,
        quantity => 1,
        quantityreceived => 0,
        datereceived => undef,
        datecancellationprinted => undef,
    };
    my $receive_order = $builder->build({ source => 'Aqorder', value => $orderinfo });
    (undef, my $received_ordernumber) = ModReceiveOrder({
            biblionumber => $order_biblio->biblionumber,
            order        => $receive_order,
            invoice      => $order_invoice,
            quantityreceived => $receive_order->{quantity},
            budget_id    => $order->{budget_id},
    });
    my $received_order = GetOrder($received_ordernumber);
    is ($received_order->{replacementprice},undef,"No price set if none passed in");
    $orderinfo->{replacementprice} = 16.12;
    $receive_order = $builder->build({ source => 'Aqorder', value => $orderinfo });
    (undef, $received_ordernumber) = ModReceiveOrder({
            biblionumber => $order_biblio->biblionumber,
            order        => $receive_order,
            invoice      => $order_invoice,
            quantityreceived => $receive_order->{quantity},
            budget_id    => $order->{budget_id},
    });
    $received_order = GetOrder($received_ordernumber);
    is ($received_order->{replacementprice},'16.120000',"Replacement price set if none passed in");
};

subtest 'ModReceiveOrder and subscription' => sub {
    plan tests => 2;

    my $builder     = t::lib::TestBuilder->new;
    my $first_note  = 'first note';
    my $second_note = 'second note';
    my $subscription = $builder->build_object( { class => 'Koha::Subscriptions' } );
    my $order = $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                subscriptionid     => $subscription->subscriptionid,
                order_internalnote => $first_note,
                quantity           => 5,
                quantityreceived   => 0,
                ecost_tax_excluded => 42,
                unitprice_tax_excluded => 42,
            }
        }
    );
    my $order_info = $order->unblessed;
    # We do not want the note from the original note to be modified
    # Keeping it will permit to display it for future receptions
    $order_info->{order_internalnote} = $second_note;
    my ( undef, $received_ordernumber ) = ModReceiveOrder(
        {
            biblionumber     => $order->biblionumber,
            order            => $order_info,
            invoice          => $order->{invoiceid},
            quantityreceived => 1,
            budget_id        => $order->budget_id,
        }
    );
    my $received_order = Koha::Acquisition::Orders->find($received_ordernumber);
    is( $received_order->order_internalnote,
        $second_note, "No price set if none passed in" );

    is( $order->get_from_storage->order_internalnote, $first_note );
};

subtest 'ModReceiveOrder invoice_unitprice and invoice_currency' => sub {
    plan tests => 2;

    my $builder = t::lib::TestBuilder->new;
    subtest 'partial order' => sub {
        plan tests => 2;

        subtest 'no invoice_unitprice' => sub {
            plan tests => 4;
            my $order = $builder->build_object(
                {
                    class => 'Koha::Acquisition::Orders',
                    value => {
                        quantity               => 5,
                        quantityreceived       => 0,
                        ecost_tax_excluded     => 42,
                        unitprice_tax_excluded => 42,
                    }
                }
            );
            my $order_info = {
                %{ $order->unblessed },
                invoice_unitprice => undef,
                invoice_currency  => undef,
            };
            my ( undef, $received_ordernumber ) = ModReceiveOrder(
                {
                    biblionumber     => $order->biblionumber,
                    order            => $order_info,
                    quantityreceived => 1,                   # We receive only 1
                    budget_id        => $order->budget_id,
                }
            );
            my $received_order =
              Koha::Acquisition::Orders->find($received_ordernumber);
            is( $received_order->invoice_unitprice,
                undef, 'no price should be stored if none passed' );
            is( $received_order->invoice_currency,
                undef, 'no currency should be stored if none passed' );
            $order = $order->get_from_storage;
            is( $order->invoice_unitprice, undef,
                'no price should be stored if none passed' );
            is( $order->invoice_currency, undef,
                'no currency should be stored if none passed' );
        };
        subtest 'with invoice_unitprice' => sub {
            plan tests => 4;
            my $order = $builder->build_object(
                {
                    class => 'Koha::Acquisition::Orders',
                    value => {
                        quantity               => 5,
                        quantityreceived       => 0,
                        ecost_tax_excluded     => 42,
                        unitprice_tax_excluded => 42,
                    }
                }
            );
            my $order_info = {
                %{ $order->unblessed },
                invoice_unitprice => 37,
                invoice_currency  => 'GBP',
            };
            my ( undef, $received_ordernumber ) = ModReceiveOrder(
                {
                    biblionumber     => $order->biblionumber,
                    order            => $order_info,
                    quantityreceived => 1,
                    budget_id        => $order->budget_id,
                }
            );
            my $received_order =
              Koha::Acquisition::Orders->find($received_ordernumber);
            is( $received_order->invoice_unitprice + 0,
                37, 'price should be stored in new order' );
            is( $received_order->invoice_currency,
                'GBP', 'currency should be stored in new order' );
            $order = $order->get_from_storage;
            is( $order->invoice_unitprice + 0,
                37, 'price should be stored in existing order' );
            is( $order->invoice_currency, 'GBP',
                'currency should be stored in existing order' );

        };
    };

    subtest 'full received order' => sub {
        plan tests => 2;

        subtest 'no invoice_unitprice' => sub {
            plan tests => 4;
            my $builder = t::lib::TestBuilder->new;
            my $order   = $builder->build_object(
                {
                    class => 'Koha::Acquisition::Orders',
                    value => {
                        quantity               => 5,
                        quantityreceived       => 0,
                        ecost_tax_excluded     => 42,
                        unitprice_tax_excluded => 42,
                    }
                }
            );
            my $order_info = {
                %{ $order->unblessed },
                invoice_unitprice => undef,
                invoice_currency  => undef,
            };
            my ( undef, $received_ordernumber ) = ModReceiveOrder(
                {
                    biblionumber => $order->biblionumber,
                    order        => $order_info,
                    quantityreceived => 5,                # We receive them all!
                    budget_id        => $order->budget_id,
                }
            );
            my $received_order =
              Koha::Acquisition::Orders->find($received_ordernumber);
            is( $received_order->invoice_unitprice,
                undef, 'no price should be stored if none passed' );
            is( $received_order->invoice_currency,
                undef, 'no currency should be stored if none passed' );
            $order = $order->get_from_storage;
            is( $order->invoice_unitprice, undef,
                'no price should be stored if none passed' );
            is( $order->invoice_currency, undef,
                'no currency should be stored if none passed' );
        };

        subtest 'with invoice_unitprice' => sub {
            plan tests => 4;
            my $order = $builder->build_object(
                {
                    class => 'Koha::Acquisition::Orders',
                    value => {
                        quantity               => 5,
                        quantityreceived       => 0,
                        ecost_tax_excluded     => 42,
                        unitprice_tax_excluded => 42,
                    }
                }
            );
            my $order_info = {
                %{ $order->unblessed },
                invoice_unitprice => 37,
                invoice_currency  => 'GBP',
            };
            my ( undef, $received_ordernumber ) = ModReceiveOrder(
                {
                    biblionumber     => $order->biblionumber,
                    order            => $order_info,
                    quantityreceived => 1,
                    budget_id        => $order->budget_id,
                }
            );
            my $received_order =
              Koha::Acquisition::Orders->find($received_ordernumber);
            is( $received_order->invoice_unitprice + 0,
                37, 'price should be stored in new order' );
            is( $received_order->invoice_currency,
                'GBP', 'currency should be stored in new order' );
            $order = $order->get_from_storage;
            is( $order->invoice_unitprice + 0,
                37, 'price should be stored in existing order' );
            is( $order->invoice_currency, 'GBP',
                'currency should be stored in existing order' );

        };
    };

};

subtest 'GetHistory with additional fields' => sub {
    plan tests => 3;
    my $builder = t::lib::TestBuilder->new;
    my $order_basket = $builder->build({ source => 'Aqbasket', value => { is_standing => 0 } });
    my $orderinfo ={
        basketno => $order_basket->{basketno},
        rrp => 19.99,
        replacementprice => undef,
        quantity => 1,
        quantityreceived => 0,
        datereceived => undef,
        datecancellationprinted => undef,
    };
    my $order =        $builder->build({ source => 'Aqorder', value => $orderinfo });
    my $history = GetHistory(ordernumber => $order->{ordernumber});
    is( scalar( @$history ), 1, 'GetHistory returns the one order');

    my $additional_field = $builder->build({source => 'AdditionalField', value => {
            tablename => 'aqbasket',
            name => 'snakeoil',
            authorised_value_category => "",
        }
    });
    $history = GetHistory( ordernumber => $order->{ordernumber}, additional_fields => [{ id => $additional_field->{id}, value=>'delicious'}]);
    is( scalar ( @$history ), 0, 'GetHistory returns no order for an unused additional field');
    my $basket = Koha::Acquisition::Baskets->find({ basketno => $order_basket->{basketno} });
    $basket->set_additional_fields([{
        id => $additional_field->{id},
        value => 'delicious',
    }]);

    $history = GetHistory( ordernumber => $order->{ordernumber}, additional_fields => [{ id => $additional_field->{id}, value=>'delicious'}]);
    is( scalar( @$history ), 1, 'GetHistory returns the order when additional field is set');
};

subtest 'Tests for get_rounding_sql' => sub {

    plan tests => 2;

    my $value = '3.141592';

    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{} );
    my $no_rounding_result = C4::Acquisition::get_rounding_sql($value);
    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{nearest_cent} );
    my $rounding_result = C4::Acquisition::get_rounding_sql($value);

    ok( $no_rounding_result eq $value, "Value ($value) not to be rounded" );
    ok( $rounding_result =~ /CAST/,    "Value ($value) will be rounded" );

};

subtest 'Test for get_rounded_price' => sub {

    plan tests => 6;

    my $exact_price      = 3.14;
    my $up_price         = 3.145592;
    my $down_price       = 3.141592;
    my $round_up_price   = sprintf( '%0.2f', $up_price );
    my $round_down_price = sprintf( '%0.2f', $down_price );

    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{} );
    my $not_rounded_result1 = C4::Acquisition::get_rounded_price($exact_price);
    my $not_rounded_result2 = C4::Acquisition::get_rounded_price($up_price);
    my $not_rounded_result3 = C4::Acquisition::get_rounded_price($down_price);
    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{nearest_cent} );
    my $rounded_result1 = C4::Acquisition::get_rounded_price($exact_price);
    my $rounded_result2 = C4::Acquisition::get_rounded_price($up_price);
    my $rounded_result3 = C4::Acquisition::get_rounded_price($down_price);

    is( $not_rounded_result1, $exact_price,      "Price ($exact_price) was correctly not rounded ($not_rounded_result1)" );
    is( $not_rounded_result2, $up_price,         "Price ($up_price) was correctly not rounded ($not_rounded_result2)" );
    is( $not_rounded_result3, $down_price,       "Price ($down_price) was correctly not rounded ($not_rounded_result3)" );
    is( $rounded_result1,     $exact_price,      "Price ($exact_price) was correctly rounded ($rounded_result1)" );
    is( $rounded_result2,     $round_up_price,   "Price ($up_price) was correctly rounded ($rounded_result2)" );
    is( $rounded_result3,     $round_down_price, "Price ($down_price) was correctly rounded ($rounded_result3)" );

};

subtest 'GetHistory - managing library' => sub {

    plan tests => 1;

    my $orders = GetHistory(managing_library => 'CPL');

    my $builder = t::lib::TestBuilder->new;

    my $order_basket1 = $builder->build({ source => 'Aqbasket', value => { branch => 'CPL' } });
    my $orderinfo1 ={
        basketno => $order_basket1->{basketno},
        rrp => 19.99,
        replacementprice => undef,
        quantity => 1,
        quantityreceived => 0,
        datereceived => undef,
        datecancellationprinted => undef,
    };
    my $order1 = $builder->build({ source => 'Aqorder', value => $orderinfo1 });

    my $order_basket2 = $builder->build({ source => 'Aqbasket', value => { branch => 'LIB' } });
    my $orderinfo2 ={
        basketno => $order_basket2->{basketno},
        rrp => 19.99,
        replacementprice => undef,
        quantity => 1,
        quantityreceived => 0,
        datereceived => undef,
        datecancellationprinted => undef,
    };
    my $order2 = $builder->build({ source => 'Aqorder', value => $orderinfo2 });

    my $history = GetHistory(managing_library => 'CPL');
    is( scalar( @$history), scalar ( @$orders ) +1, "GetHistory returns number of orders");

};

subtest 'GetHistory - is_standing' => sub {

    plan tests => 1;

    my $orders = GetHistory( is_standing => '1' );

    my $builder = t::lib::TestBuilder->new;

    my $order_basket1 = $builder->build( { source => 'Aqbasket', value => { is_standing => 0 } } );
    my $orderinfo1 = {
        basketno                => $order_basket1->{basketno},
        rrp                     => 19.99,
        replacementprice        => undef,
        quantity                => 1,
        quantityreceived        => 0,
        datereceived            => undef,
        datecancellationprinted => undef,
    };
    my $order1 = $builder->build( { source => 'Aqorder', value => $orderinfo1 } );

    my $order_basket2 = $builder->build( { source => 'Aqbasket', value => { is_standing => 1 } } );
    my $orderinfo2 = {
        basketno                => $order_basket2->{basketno},
        rrp                     => 19.99,
        replacementprice        => undef,
        quantity                => 1,
        quantityreceived        => 0,
        datereceived            => undef,
        datecancellationprinted => undef,
    };
    my $order2 = $builder->build( { source => 'Aqorder', value => $orderinfo2 } );

    my $history = GetHistory( is_standing => 1 );
    is(
        scalar(@$history),
        scalar(@$orders) + 1,
        "GetHistory returns number of standing orders"
    );

};

subtest 'Acquisition logging' => sub {

    plan tests => 5;

    t::lib::Mocks::mock_preference('AcquisitionLog', 1);

    Koha::ActionLogs->delete;
    my $basketno = NewBasket( $booksellerid, 1 );
    my @create_logs = Koha::ActionLogs->search({ module =>'ACQUISITIONS', action => 'ADD_BASKET', object => $basketno })->as_list;
    is (scalar @create_logs, 1, 'Basket creation is logged');

    Koha::ActionLogs->delete;
    C4::Acquisition::ReopenBasket($basketno);
    my @reopen_logs = Koha::ActionLogs->search({ module =>'ACQUISITIONS', action => 'REOPEN_BASKET', object => $basketno })->as_list;
    is (scalar @reopen_logs, 1, 'Basket reopen is logged');

    Koha::ActionLogs->delete;
    C4::Acquisition::ModBasket({
        basketno => $basketno,
        booksellerid => $booksellerid
    });
    my @mod_logs = Koha::ActionLogs->search({ module =>'ACQUISITIONS', action => 'MODIFY_BASKET', object => $basketno })->as_list;
    is (scalar @mod_logs, 1, 'Basket modify is logged');

    Koha::ActionLogs->delete;
    C4::Acquisition::ModBasketHeader($basketno,"Test","","","",$booksellerid);
    my @mod_header_logs = Koha::ActionLogs->search({ module =>'ACQUISITIONS', action => 'MODIFY_BASKET_HEADER', object => $basketno })->as_list;
    is (scalar @mod_header_logs, 1, 'Basket header modify is logged');

    Koha::ActionLogs->delete;
    C4::Acquisition::ModBasketUsers($basketno,(1));
    my @mod_users_logs = Koha::ActionLogs->search({ module =>'ACQUISITIONS', action => 'MODIFY_BASKET_USERS', object => $basketno })->as_list;
    is (scalar @mod_users_logs, 1, 'Basket users modify is logged');

    t::lib::Mocks::mock_preference('AcquisitionLog', 0);
};

$schema->storage->txn_rollback();

subtest 'GetInvoices() tests with additional fields' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $invoice_1 = $builder->build_object(
        {
             class => 'Koha::Acquisition::Invoices',
             value => {
                invoicenumber => 'whataretheodds1'
             }
        }
    );
    my $invoice_2 = $builder->build_object(
        {
             class => 'Koha::Acquisition::Invoices',
             value => {
                invoicenumber => 'whataretheodds2'
             }
        }
    );


    my $invoices = [ GetInvoices( invoicenumber => 'whataretheodds' ) ];
    is( scalar @{$invoices}, 2, 'Two invoices retrieved' );
    is( $invoices->[0]->{invoiceid}, $invoice_1->id );
    is( $invoices->[1]->{invoiceid}, $invoice_2->id );

    my $additional_field_1 = $builder->build_object(
        {   class => 'Koha::AdditionalFields',
            value => {
                tablename                 => 'aqinvoices',
                authorised_value_category => "",
            }
        }
    );

    my $additional_field_2 = $builder->build_object(
        {   class => 'Koha::AdditionalFields',
            value => {
                tablename                 => 'aqinvoices',
                authorised_value_category => "",
            }
        }
    );

    $invoice_1->set_additional_fields([ { id => $additional_field_1->id, value => 'Ya-Hey' } ]);
    $invoice_2->set_additional_fields([ { id => $additional_field_2->id, value => "Hey ho let's go" } ]);

    $invoices = [ GetInvoices(
        invoicenumber => 'whataretheodds',
        additional_fields => [{ id => $additional_field_1->id, value => 'Ya-Hey' }]
    )];
    is( scalar @{$invoices}, 1, 'One invoice retrieved' );
    is( $invoices->[0]->{invoiceid}, $invoice_1->id, 'Ya-Hey' );

    $invoices = [ GetInvoices(
        invoicenumber => 'whataretheodds',
        additional_fields => [{ id => $additional_field_2->id, value => "Hey ho let's go" }]
    )];
    is( scalar @{$invoices}, 1, 'One invoice retrieved' );
    is( $invoices->[0]->{invoiceid}, $invoice_2->id, "Hey ho let's go" );

    $schema->storage->txn_rollback;
};
