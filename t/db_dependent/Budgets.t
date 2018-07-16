#!/usr/bin/perl
use Modern::Perl;
use Test::More tests => 145;

BEGIN {
    use_ok('C4::Budgets')
}
use C4::Context;
use C4::Biblio;
use C4::Acquisition;

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use Koha::Patrons;

use t::lib::TestBuilder;

use YAML;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM aqbudgetperiods|);
$dbh->do(q|DELETE FROM aqbudgets|);

my $library = $builder->build({
    source => 'Branch',
});

# Mock userenv
local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
my $userenv;
*C4::Context::userenv = \&Mock_userenv;
$userenv = { flags => 1, id => 'my_userid', branch => $library->{branchcode} };

#
# Budget Periods :
#

is( AddBudgetPeriod(), undef, 'AddBugetPeriod without argument returns undef' );
is( AddBudgetPeriod( { }  ), undef, 'AddBugetPeriod with an empty argument returns undef' );
my $bpid = AddBudgetPeriod({
    budget_period_startdate => '2008-01-01',
});
is( $bpid, undef, 'AddBugetPeriod without end date returns undef' );
$bpid = AddBudgetPeriod({
    budget_period_enddate => '2008-12-31',
});
is( $bpid, undef, 'AddBugetPeriod without start date returns undef' );
is( GetBudgetPeriod(0), undef ,'GetBudgetPeriod(0) returned undef : noactive BudgetPeriod' );
my $budgetperiods = GetBudgetPeriods();
is( @$budgetperiods, 0, 'GetBudgetPeriods returns the correct number of budget periods' );

my $my_budgetperiod = {
    budget_period_startdate   => '2008-01-01',
    budget_period_enddate     => '2008-12-31',
    budget_period_description => 'MAPERI',
    budget_period_active      => 0,
};
$bpid = AddBudgetPeriod($my_budgetperiod);
isnt( $bpid, undef, 'AddBugetPeriod does not returns undef' );
my $budgetperiod = GetBudgetPeriod($bpid);
is( $budgetperiod->{budget_period_startdate}, $my_budgetperiod->{budget_period_startdate}, 'AddBudgetPeriod stores the start date correctly' );
is( $budgetperiod->{budget_period_enddate}, $my_budgetperiod->{budget_period_enddate}, 'AddBudgetPeriod stores the end date correctly' );
is( $budgetperiod->{budget_period_description}, $my_budgetperiod->{budget_period_description}, 'AddBudgetPeriod stores the description correctly' );
is( $budgetperiod->{budget_period_active}, $my_budgetperiod->{budget_period_active}, 'AddBudgetPeriod stores active correctly' );
is( GetBudgetPeriod(0), undef ,'GetBudgetPeriod(0) returned undef : noactive BudgetPeriod' );


$my_budgetperiod = {
    budget_period_startdate   => '2009-01-01',
    budget_period_enddate     => '2009-12-31',
    budget_period_description => 'MODIF_MAPERI',
    budget_period_active      => 1,
};
my $mod_status = ModBudgetPeriod($my_budgetperiod);
is( $mod_status, undef, 'ModBudgetPeriod without id returns undef' );

$my_budgetperiod->{budget_period_id} = $bpid;
$mod_status = ModBudgetPeriod($my_budgetperiod);
is( $mod_status, 1, 'ModBudgetPeriod returnis true' );
$budgetperiod = GetBudgetPeriod($bpid);
is( $budgetperiod->{budget_period_startdate}, $my_budgetperiod->{budget_period_startdate}, 'ModBudgetPeriod updates the start date correctly' );
is( $budgetperiod->{budget_period_enddate}, $my_budgetperiod->{budget_period_enddate}, 'ModBudgetPeriod updates the end date correctly' );
is( $budgetperiod->{budget_period_description}, $my_budgetperiod->{budget_period_description}, 'ModBudgetPeriod updates the description correctly' );
is( $budgetperiod->{budget_period_active}, $my_budgetperiod->{budget_period_active}, 'ModBudgetPeriod upates active correctly' );
isnt( GetBudgetPeriod(0), undef, 'GetBugetPeriods functions correctly' );


$budgetperiods = GetBudgetPeriods();
is( @$budgetperiods, 1, 'GetBudgetPeriods returns the correct number of budget periods' );
is( $budgetperiods->[0]->{budget_period_id}, $my_budgetperiod->{budget_period_id}, 'GetBudgetPeriods returns the id correctly' );
is( $budgetperiods->[0]->{budget_period_startdate}, $my_budgetperiod->{budget_period_startdate}, 'GetBudgetPeriods returns the start date correctly' );
is( $budgetperiods->[0]->{budget_period_enddate}, $my_budgetperiod->{budget_period_enddate}, 'GetBudgetPeriods returns the end date correctly' );
is( $budgetperiods->[0]->{budget_period_description}, $my_budgetperiod->{budget_period_description}, 'GetBudgetPeriods returns the description correctly' );
is( $budgetperiods->[0]->{budget_period_active}, $my_budgetperiod->{budget_period_active}, 'GetBudgetPeriods returns active correctly' );

is( DelBudgetPeriod($bpid), 1, 'DelBudgetPeriod returns true' );
$budgetperiods = GetBudgetPeriods();
is( @$budgetperiods, 0, 'GetBudgetPeriods returns the correct number of budget periods' );


#
# Budget  :
#

# The budget hierarchy will be:
# budget_1
#   budget_11
#     budget_111
#   budget_12
# budget_2
#   budget_21

is( AddBudget(), undef, 'AddBuget without argument returns undef' );
my $budgets = GetBudgets();
is( @$budgets, 0, 'GetBudgets returns the correct number of budgets' );

$bpid = AddBudgetPeriod($my_budgetperiod); #this is an active budget

my $my_budget = {
    budget_code      => 'ABCD',
    budget_amount    => '123.132000',
    budget_name      => 'Periodiques',
    budget_notes     => 'This is a note',
    budget_period_id => $bpid,
};
my $budget_id = AddBudget($my_budget);
isnt( $budget_id, undef, 'AddBudget does not returns undef' );
my $budget = GetBudget($budget_id);
is( $budget->{budget_code}, $my_budget->{budget_code}, 'AddBudget stores the budget code correctly' );
is( $budget->{budget_amount}, $my_budget->{budget_amount}, 'AddBudget stores the budget amount correctly' );
is( $budget->{budget_name}, $my_budget->{budget_name}, 'AddBudget stores the budget name correctly' );
is( $budget->{budget_notes}, $my_budget->{budget_notes}, 'AddBudget stores the budget notes correctly' );
is( $budget->{budget_period_id}, $my_budget->{budget_period_id}, 'AddBudget stores the budget period id correctly' );


$my_budget = {
    budget_code      => 'EFG',
    budget_amount    => '321.231000',
    budget_name      => 'Modified name',
    budget_notes     => 'This is a modified note',
    budget_period_id => $bpid,
};
$mod_status = ModBudget($my_budget);
is( $mod_status, undef, 'ModBudget without id returns undef' );

$my_budget->{budget_id} = $budget_id;
$mod_status = ModBudget($my_budget);
is( $mod_status, 1, 'ModBudget returns true' );
$budget = GetBudget($budget_id);
is( $budget->{budget_code}, $my_budget->{budget_code}, 'ModBudget updates the budget code correctly' );
is( $budget->{budget_amount}, $my_budget->{budget_amount}, 'ModBudget updates the budget amount correctly' );
is( $budget->{budget_name}, $my_budget->{budget_name}, 'ModBudget updates the budget name correctly' );
is( $budget->{budget_notes}, $my_budget->{budget_notes}, 'ModBudget updates the budget notes correctly' );
is( $budget->{budget_period_id}, $my_budget->{budget_period_id}, 'ModBudget updates the budget period id correctly' );


$budgets = GetBudgets();
is( @$budgets, 1, 'GetBudgets returns the correct number of budgets' );
is( $budgets->[0]->{budget_id}, $my_budget->{budget_id}, 'GetBudgets returns the budget id correctly' );
is( $budgets->[0]->{budget_code}, $my_budget->{budget_code}, 'GetBudgets returns the budget code correctly' );
is( $budgets->[0]->{budget_amount}, $my_budget->{budget_amount}, 'GetBudgets returns the budget amount correctly' );
is( $budgets->[0]->{budget_name}, $my_budget->{budget_name}, 'GetBudgets returns the budget name correctly' );
is( $budgets->[0]->{budget_notes}, $my_budget->{budget_notes}, 'GetBudgets returns the budget notes correctly' );
is( $budgets->[0]->{budget_period_id}, $my_budget->{budget_period_id}, 'GetBudgets returns the budget period id correctly' );

$budgets = GetBudgets( {budget_period_id => $bpid} );
is( @$budgets, 1, 'GetBudgets With Filter OK' );
$budgets = GetBudgets( {budget_period_id => $bpid}, {-asc => "budget_name"} );
is( @$budgets, 1, 'GetBudgets With Order OK' );
$budgets = GetBudgets( {budget_period_id => GetBudgetPeriod($bpid)->{budget_period_id}}, {-asc => "budget_name"} );
is( @$budgets, 1, 'GetBudgets With Order Getting Active budgetPeriod OK');


my $budget_name = GetBudgetName( $budget_id );
is($budget_name, $my_budget->{budget_name}, "Test the GetBudgetName routine");

my $my_inactive_budgetperiod = { #let's add an inactive
    budget_period_startdate   => '2010-01-01',
    budget_period_enddate     => '2010-12-31',
    budget_period_description => 'MODIF_MAPERI',
    budget_period_active      => 0,
};
my $bpid_i = AddBudgetPeriod($my_inactive_budgetperiod); #this is an inactive budget

my $my_budget_inactive = {
    budget_code      => 'EFG',
    budget_amount    => '123.132000',
    budget_name      => 'Periodiques',
    budget_notes     => 'This is a note',
    budget_period_id => $bpid_i,
};
my $budget_id_inactive = AddBudget($my_budget_inactive);

my $budget_code = $my_budget->{budget_code};
my $budget_by_code = GetBudgetByCode( $budget_code );
is($budget_by_code->{budget_id}, $budget_id, "GetBudgetByCode, check id"); #this should match the active budget, not the inactive
is($budget_by_code->{budget_notes}, $my_budget->{budget_notes}, "GetBudgetByCode, check notes");

my $second_budget_id = AddBudget({
    budget_code      => "ZZZZ",
    budget_amount    => "500.00",
    budget_name      => "Art",
    budget_notes     => "This is a note",
    budget_period_id => $bpid,
});
isnt( $second_budget_id, undef, 'AddBudget does not returns undef' );

$budgets = GetBudgets( {budget_period_id => $bpid} );
ok( $budgets->[0]->{budget_name} lt $budgets->[1]->{budget_name}, 'default sort order for GetBudgets is by name' );

is( DelBudget($budget_id), 1, 'DelBudget returns true' );
$budgets = GetBudgets();
is( @$budgets, 2, 'GetBudgets returns the correct number of budget periods' );


# GetBudgetHierarchySpent and GetBudgetHierarchyOrdered
my $budget_period_total = 10_000;
my $budget_1_total = 1_000;
my $budget_11_total = 100;
my $budget_111_total = 50;
my $budget_12_total = 100;
my $budget_2_total = 2_000;

my $budget_period_id = AddBudgetPeriod(
    {
        budget_period_startdate   => '2013-01-01',
        budget_period_enddate     => '2014-12-31',
        budget_period_description => 'Budget Period',
        budget_period_active      => 1,
        budget_period_total       => $budget_period_total,
    }
);
my $budget_id1 = AddBudget(
    {
        budget_code      => 'budget_1',
        budget_name      => 'budget_1',
        budget_period_id => $budget_period_id,
        budget_parent_id => undef,
        budget_amount    => $budget_1_total,
    }
);
my $budget_id2 = AddBudget(
    {
        budget_code      => 'budget_2',
        budget_name      => 'budget_2',
        budget_period_id => $budget_period_id,
        budget_parent_id => undef,
        budget_amount    => $budget_2_total,
    }
);
my $budget_id12 = AddBudget(
    {
        budget_code      => 'budget_12',
        budget_name      => 'budget_12',
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id1,
        budget_amount    => $budget_12_total,
    }
);
my $budget_id11 = AddBudget(
    {
        budget_code      => 'budget_11',
        budget_name      => 'budget_11',
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id1,
        budget_amount    => $budget_11_total,
    }
);
my $budget_id111 = AddBudget(
    {
        budget_code      => 'budget_111',
        budget_name      => 'budget_111',
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id11,
        budget_owner_id  => 1,
        budget_amount    => $budget_111_total,
    }
);
my $budget_id21 = AddBudget(
    {
        budget_code      => 'budget_21',
        budget_name      => 'budget_21',
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id2,
    }
);

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

my $basketno = C4::Acquisition::NewBasket( $booksellerid, 1 );
my ( $biblionumber, $biblioitemnumber ) =
  C4::Biblio::AddBiblio( MARC::Record->new, '' );

my @order_infos = (
    {
        budget_id => $budget_id1,
        pending_quantity  => 1,
        spent_quantity  => 0,
    },
    {
        budget_id => $budget_id2,
        pending_quantity  => 2,
        spent_quantity  => 1,
    },
    {
        budget_id => $budget_id11,
        pending_quantity  => 3,
        spent_quantity  => 4,
    },
    {
        budget_id => $budget_id12,
        pending_quantity  => 4,
        spent_quantity  => 3,
    },
    {
        budget_id => $budget_id111,
        pending_quantity  => 2,
        spent_quantity  => 1,
    },

    # No order for budget_21

);

my %budgets;
my $invoiceid = AddInvoice(invoicenumber => 'invoice_test_clone', booksellerid => $booksellerid, unknown => "unknown");
my $invoice = GetInvoice( $invoiceid );
my $item_price = 10;
my $item_quantity = 2;
my $number_of_orders_to_move = 0;
for my $infos (@order_infos) {
    for ( 1 .. $infos->{pending_quantity} ) {
        my $order = Koha::Acquisition::Order->new(
            {
                basketno           => $basketno,
                biblionumber       => $biblionumber,
                budget_id          => $infos->{budget_id},
                order_internalnote => "internal note",
                order_vendornote   => "vendor note",
                quantity           => 2,
                cost_tax_included  => $item_price,
                rrp_tax_included   => $item_price,
                listprice          => $item_price,
                ecost_tax_include  => $item_price,
                discount           => 0,
                uncertainprice     => 0,
            }
        )->store;
        my $ordernumber = $order->ordernumber;
        push @{ $budgets{$infos->{budget_id}} }, $ordernumber;
        $number_of_orders_to_move++;
    }
    for ( 1 .. $infos->{spent_quantity} ) {
        my $order = Koha::Acquisition::Order->new(
            {
                basketno           => $basketno,
                biblionumber       => $biblionumber,
                budget_id          => $infos->{budget_id},
                order_internalnote => "internal note",
                order_vendornote   => "vendor note",
                quantity           => $item_quantity,
                cost               => $item_price,
                rrp_tax_included   => $item_price,
                listprice          => $item_price,
                ecost_tax_included => $item_price,
                discount           => 0,
                uncertainprice     => 0,
            }
        )->store;
        my $ordernumber = $order->ordernumber;
        ModReceiveOrder({
              biblionumber     => $biblionumber,
              order            => $order->unblessed,
              budget_id        => $infos->{budget_id},
              quantityreceived => $item_quantity,
              invoice          => $invoice,
              received_items   => [],
        } );
    }
}
is( GetBudgetHierarchySpent( $budget_id1 ), 160, "total spent for budget1 is 160" );
is( GetBudgetHierarchySpent( $budget_id11 ), 100, "total spent for budget11 is 100" );
is( GetBudgetHierarchySpent( $budget_id111 ), 20, "total spent for budget111 is 20" );

# GetBudgetSpent and GetBudgetOrdered
my $budget_period_amount = 100;
my $budget_amount = 50;

$budget = AddBudgetPeriod(
    {
        budget_period_startdate   => '2017-08-22',
        budget_period_enddate     => '2018-08-22',
        budget_period_description => 'Test budget',
        budget_period_active      => 1,
        budget_period_total       => $budget_period_amount,
    }
);

my $fund = AddBudget(
    {
        budget_code       => 'Test fund',
        budget_name       => 'Test fund',
        budget_period_id  => $budget,
        budget_parent_id  => undef,
        budget_amount     => $budget_amount,
    }
);

my $vendor = Koha::Acquisition::Bookseller->new(
    {
        name         => "test vendor",
        address1     => "test address",
        phone        => "0123456",
        active       => 1,
        deliverytime => 5,
    }
)->store;

my $vendorid = $vendor->id;

my $basketnumber = C4::Acquisition::NewBasket( $vendorid, 1 );
my ( $biblio, $biblioitem ) = C4::Biblio::AddBiblio( MARC::Record->new, '' );

my @orders = (
    {
        budget_id  => $fund,
        pending_quantity => 1,
        spent_quantity => 0,
    },
);

my $invoiceident = AddInvoice( invoicenumber => 'invoice_test_clone', booksellerid => $vendorid, shipmentdate => '2017-08-22', shipmentcost => 6, shipmentcost_budgetid => $fund );
my $test_invoice = GetInvoice( $invoiceident );
my $individual_item_price = 10;

my $order = Koha::Acquisition::Order->new(
   {
      basketno           => $basketnumber,
      biblionumber       => $biblio,
      budget_id          => $fund,
      order_internalnote => "internalnote",
      order_vendornote   => "vendor note",
      quantity           => 2,
      cost_tax_included  => $individual_item_price,
      rrp_tax_included   => $individual_item_price,
      listprice          => $individual_item_price,
      ecost_tax_included => $individual_item_price,
      discount           => 0,
      uncertainprice     => 0,
   }
)->store;

ModReceiveOrder({
   bibionumber       => $biblio,
   order             => $order->unblessed,
   budget_id         => $fund,
   quantityreceived  => 2,
   invoice           => $test_invoice,
   received_items    => [],
} );

is ( GetBudgetSpent( $fund ), 6, "total shipping cost is 6");
is ( GetBudgetOrdered( $fund ), '20', "total ordered price is 20");


# CloneBudgetPeriod
my $budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
        budget_period_description => 'Budget Period Cloned',
    }
);

my $budget_period_cloned = C4::Budgets::GetBudgetPeriod($budget_period_id_cloned);
is($budget_period_cloned->{budget_period_description}, 'Budget Period Cloned', 'Cloned budget\'s description is updated.');

my $budget_hierarchy        = GetBudgetHierarchy($budget_period_id);
my $budget_hierarchy_cloned = GetBudgetHierarchy($budget_period_id_cloned);

is(
    scalar(@$budget_hierarchy_cloned),
    scalar(@$budget_hierarchy),
    'CloneBudgetPeriod clones the same number of budgets (funds)'
);
is_deeply(
    _get_dependencies($budget_hierarchy),
    _get_dependencies($budget_hierarchy_cloned),
    'CloneBudgetPeriod keeps the same dependencies order'
);

# CloneBudgetPeriod with param mark_original_budget_as_inactive
my $budget_period = C4::Budgets::GetBudgetPeriod($budget_period_id);
is( $budget_period->{budget_period_active}, 1,
    'CloneBudgetPeriod does not mark as inactive the budgetperiod if not needed'
);

$budget_hierarchy_cloned = GetBudgetHierarchy($budget_period_id_cloned);
my $number_of_budgets_not_reset = 0;
for my $budget (@$budget_hierarchy_cloned) {
    $number_of_budgets_not_reset++ if $budget->{budget_amount} > 0;
}
is( $number_of_budgets_not_reset, 5,
    'CloneBudgetPeriod does not reset budgets (funds) if not needed' );

$budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id                 => $budget_period_id,
        budget_period_startdate          => '2014-01-01',
        budget_period_enddate            => '2014-12-31',
        mark_original_budget_as_inactive => 1,
    }
);

$budget_hierarchy        = GetBudgetHierarchy($budget_period_id);
is( $budget_hierarchy->[0]->{children}->[0]->{budget_name}, 'budget_11', 'GetBudgetHierarchy should return budgets ordered by name, first child is budget_11' );
is( $budget_hierarchy->[0]->{children}->[1]->{budget_name}, 'budget_12', 'GetBudgetHierarchy should return budgets ordered by name, second child is budget_12' );
is($budget_hierarchy->[0]->{budget_name},'budget_1','GetBudgetHierarchy should return budgets ordered by name, first budget is budget_1');
is($budget_hierarchy->[0]->{budget_level},'0','budget_level of budget (budget_1)  should be 0');
is($budget_hierarchy->[0]->{children}->[0]->{budget_level},'1','budget_level of first fund(budget_11)  should be 1');
is($budget_hierarchy->[0]->{children}->[1]->{budget_level},'1','budget_level of second fund(budget_12)  should be 1');
is($budget_hierarchy->[0]->{children}->[0]->{children}->[0]->{budget_level},'2','budget_level of  child fund budget_11 should be 2');
$budget_hierarchy        = GetBudgetHierarchy($budget_period_id);
$budget_hierarchy_cloned = GetBudgetHierarchy($budget_period_id_cloned);

is( scalar(@$budget_hierarchy_cloned), scalar(@$budget_hierarchy),
'CloneBudgetPeriod (with inactive param) clones the same number of budgets (funds)'
);
is_deeply(
    _get_dependencies($budget_hierarchy),
    _get_dependencies($budget_hierarchy_cloned),
    'CloneBudgetPeriod (with inactive param) keeps the same dependencies order'
);
$budget_period = C4::Budgets::GetBudgetPeriod($budget_period_id);
is( $budget_period->{budget_period_active}, 0,
    'CloneBudgetPeriod (with inactive param) marks as inactive the budgetperiod'
);

# CloneBudgetPeriod with param reset_all_budgets
$budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
        reset_all_budgets         => 1,
    }
);

$budget_hierarchy_cloned     = GetBudgetHierarchy($budget_period_id_cloned);
$number_of_budgets_not_reset = 0;
for my $budget (@$budget_hierarchy_cloned) {
    $number_of_budgets_not_reset++ if $budget->{budget_amount} > 0;
}
is( $number_of_budgets_not_reset, 0,
    'CloneBudgetPeriod has reset all budgets (funds)' );

#GetBudgetsByActivity
my $result=C4::Budgets::GetBudgetsByActivity(1);
isnt( $result, undef ,'GetBudgetsByActivity return correct value with parameter 1');
$result=C4::Budgets::GetBudgetsByActivity(0);
 isnt( $result, undef ,'GetBudgetsByActivity return correct value with parameter 0');
$result=C4::Budgets::GetBudgetsByActivity();
 is( $result, 0 , 'GetBudgetsByActivity return 0 with none parameter or other 0 or 1' );
DelBudget($budget_id);
DelBudgetPeriod($bpid);

# CloneBudgetPeriod with param amount_change_*
$budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
        amount_change_percentage => 16,
        amount_change_round_increment => 5,
    }
);

$budget_period_cloned = C4::Budgets::GetBudgetPeriod($budget_period_id_cloned);
cmp_ok($budget_period_cloned->{budget_period_total}, '==', 11600, "CloneBudgetPeriod changed correctly budget amount");
$budget_hierarchy_cloned     = GetBudgetHierarchy($budget_period_id_cloned);
cmp_ok($budget_hierarchy_cloned->[0]->{budget_amount}, '==', 1160, "CloneBudgetPeriod changed correctly funds amounts");
cmp_ok($budget_hierarchy_cloned->[1]->{budget_amount}, '==', 115, "CloneBudgetPeriod changed correctly funds amounts");
cmp_ok($budget_hierarchy_cloned->[2]->{budget_amount}, '==', 55, "CloneBudgetPeriod changed correctly funds amounts");
cmp_ok($budget_hierarchy_cloned->[3]->{budget_amount}, '==', 115, "CloneBudgetPeriod changed correctly funds amounts");
cmp_ok($budget_hierarchy_cloned->[4]->{budget_amount}, '==', 2320, "CloneBudgetPeriod changed correctly funds amounts");
cmp_ok($budget_hierarchy_cloned->[5]->{budget_amount}, '==', 0, "CloneBudgetPeriod changed correctly funds amounts");

$budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
        amount_change_percentage => 16,
        amount_change_round_increment => 5,
        reset_all_budgets => 1,
    }
);
$budget_hierarchy_cloned     = GetBudgetHierarchy($budget_period_id_cloned);
cmp_ok($budget_hierarchy_cloned->[0]->{budget_amount}, '==', 0, "CloneBudgetPeriod reset all fund amounts");

# MoveOrders
my $number_orders_moved = C4::Budgets::MoveOrders();
is( $number_orders_moved, undef, 'MoveOrders return undef if no arg passed' );
$number_orders_moved =
  C4::Budgets::MoveOrders( { from_budget_period_id => $budget_period_id } );
is( $number_orders_moved, undef,
    'MoveOrders return undef if only 1 arg passed' );
$number_orders_moved =
  C4::Budgets::MoveOrders( { to_budget_period_id => $budget_period_id } );
is( $number_orders_moved, undef,
    'MoveOrders return undef if only 1 arg passed' );
$number_orders_moved = C4::Budgets::MoveOrders(
    {
        from_budget_period_id => $budget_period_id,
        to_budget_period_id   => $budget_period_id
    }
);
is( $number_orders_moved, undef,
    'MoveOrders return undef if 2 budget period id are the same' );

$budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
    }
);

my $report = C4::Budgets::MoveOrders(
    {
        from_budget_period_id  => $budget_period_id,
        to_budget_period_id    => $budget_period_id_cloned,
        move_remaining_unspent => 1,
    }
);
is( scalar( @$report ), 6 , "MoveOrders has processed 6 funds" );

my $number_of_orders_moved = 0;
$number_of_orders_moved += scalar( @{ $_->{orders_moved} } ) for @$report;
is( $number_of_orders_moved, $number_of_orders_to_move, "MoveOrders has moved $number_of_orders_to_move orders" );

my @new_budget_ids = map { $_->{budget_id} }
  @{ C4::Budgets::GetBudgetHierarchy($budget_period_id_cloned) };
my @old_budget_ids = map { $_->{budget_id} }
  @{ C4::Budgets::GetBudgetHierarchy($budget_period_id) };
for my $budget_id ( keys %budgets ) {
    for my $ordernumber ( @{ $budgets{$budget_id} } ) {
        my $budget            = GetBudgetByOrderNumber($ordernumber);
        my $is_in_new_budgets = grep /^$budget->{budget_id}$/, @new_budget_ids;
        my $is_in_old_budgets = grep /^$budget->{budget_id}$/, @old_budget_ids;
        is( $is_in_new_budgets, 1, "MoveOrders changed the budget_id for order $ordernumber" );
        is( $is_in_old_budgets, 0, "MoveOrders changed the budget_id for order $ordernumber" );
    }
}


# MoveOrders with param move_remaining_unspent
my @new_budgets = @{ C4::Budgets::GetBudgetHierarchy($budget_period_id_cloned) };
my @old_budgets = @{ C4::Budgets::GetBudgetHierarchy($budget_period_id) };

for my $new_budget ( @new_budgets ) {
    my ( $old_budget ) = map { $_->{budget_code} eq $new_budget->{budget_code} ? $_ : () } @old_budgets;
    my $new_budget_amount_should_be = $old_budget->{budget_amount} * 2 - $old_budget->{total_spent};
    is( $new_budget->{budget_amount} + 0, $new_budget_amount_should_be, "MoveOrders updated the budget amount with the previous unspent budget (for budget $new_budget->{budget_code})" );
}

# Test SetOwnerToFundHierarchy

my $patron_category = $builder->build({ source => 'Category' });
my $branchcode = $library->{branchcode};
my $john_doe = Koha::Patron->new({
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $patron_category->{categorycode},
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe'
})->store->borrowernumber;

C4::Budgets::SetOwnerToFundHierarchy( $budget_id1, $john_doe );
is( C4::Budgets::GetBudget($budget_id1)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe for budget 1 ($budget_id1)" );
is( C4::Budgets::GetBudget($budget_id11)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe for budget 11 ($budget_id11)" );
is( C4::Budgets::GetBudget($budget_id111)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe for budget 111 ($budget_id111)" );
is( C4::Budgets::GetBudget($budget_id12)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe for budget 12 ($budget_id12 )" );
is( C4::Budgets::GetBudget($budget_id2)->{budget_owner_id},
    undef, "SetOwnerToFundHierarchy should not have set an owner for budget 2 ($budget_id2)" );
is( C4::Budgets::GetBudget($budget_id21)->{budget_owner_id},
    undef, "SetOwnerToFundHierarchy should not have set an owner for budget 21 ($budget_id21)" );

my $jane_doe = Koha::Patron->new({
    cardnumber   => '789012',
    firstname    => 'Jane',
    surname      => 'Doe',
    categorycode => $patron_category->{categorycode},
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jane.doe'
})->store->borrowernumber;

C4::Budgets::SetOwnerToFundHierarchy( $budget_id11, $jane_doe );
is( C4::Budgets::GetBudget($budget_id1)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe $john_doe for budget 1 ($budget_id1)" );
is( C4::Budgets::GetBudget($budget_id11)->{budget_owner_id},
    $jane_doe, "SetOwnerToFundHierarchy should have set John Doe $jane_doe for budget 11 ($budget_id11)" );
is( C4::Budgets::GetBudget($budget_id111)->{budget_owner_id},
    $jane_doe, "SetOwnerToFundHierarchy should have set John Doe $jane_doe for budget 111 ($budget_id111)" );
is( C4::Budgets::GetBudget($budget_id12)->{budget_owner_id},
    $john_doe, "SetOwnerToFundHierarchy should have set John Doe $john_doe for budget 12 ($budget_id12 )" );
is( C4::Budgets::GetBudget($budget_id2)->{budget_owner_id},
    undef, "SetOwnerToFundHierarchy should have set John Doe $john_doe for budget 2 ($budget_id2)" );
is( C4::Budgets::GetBudget($budget_id21)->{budget_owner_id},
    undef, "SetOwnerToFundHierarchy should have set John Doe $john_doe for budget 21 ($budget_id21)" );

# Test GetBudgetAuthCats

my $budgetPeriodId = AddBudgetPeriod({
    budget_period_startdate   => '2008-01-01',
    budget_period_enddate     => '2008-12-31',
    budget_period_description => 'just another budget',
    budget_period_active      => 0,
});

$budgets = GetBudgets();
my $i = 0;
for my $budget ( @$budgets )
{
    $budget->{sort1_authcat} = "sort1_authcat_$i";
    $budget->{sort2_authcat} = "sort2_authcat_$i";
    $budget->{budget_period_id} = $budgetPeriodId;
    ModBudget( $budget );
    $i++;
}

my $authCat = GetBudgetAuthCats($budgetPeriodId);

is( scalar @{$authCat}, $i * 2, "GetBudgetAuthCats returns only non-empty sorting categories (no empty authCat in db)" );

$i = 0;
for my $budget ( @$budgets )
{
    $budget->{sort1_authcat} = "sort_authcat_$i";
    $budget->{sort2_authcat} = "sort_authcat_$i";
    $budget->{budget_period_id} = $budgetPeriodId;
    ModBudget( $budget );
    $i++;
}

$authCat = GetBudgetAuthCats($budgetPeriodId);
is( scalar @$authCat, scalar @$budgets, "GetBudgetAuthCats returns distinct authCat" );

$i = 0;
for my $budget ( @$budgets )
{
    $budget->{sort1_authcat} = "sort1_authcat_$i";
    $budget->{sort2_authcat} = "";
    $budget->{budget_period_id} = $budgetPeriodId;
    ModBudget( $budget );
    $i++;
}

$authCat = GetBudgetAuthCats($budgetPeriodId);

is( scalar @{$authCat}, $i, "GetBudgetAuthCats returns only non-empty sorting categories (empty sort2_authcat on all records)" );

$i = 0;
for my $budget ( @$budgets )
{
    $budget->{sort1_authcat} = "";
    $budget->{sort2_authcat} = "";
    $budget->{budget_period_id} = $budgetPeriodId;
    ModBudget( $budget );
    $i++;
}

$authCat = GetBudgetAuthCats($budgetPeriodId);

is( scalar @{$authCat}, 0, "GetBudgetAuthCats returns only non-empty sorting categories (all empty)" );

# /Test GetBudgetAuthCats

subtest 'GetBudgetSpent and GetBudgetOrdered' => sub {
    plan tests => 10;

    my $budget = $builder->build({
        source => 'Aqbudget',
        value  => {
            budget_amount => 1000,
        }
    });
    my $invoice = $builder->build({
        source => 'Aqinvoice',
        value  => {
            closedate => undef,
        }
    });

    my $spent = GetBudgetSpent( $budget->{budget_id} );
    my $ordered = GetBudgetOrdered( $budget->{budget_id} );

    is( $spent, 0, "New budget, no orders/invoices, should be nothing spent");
    is( $ordered, 0, "New budget, no orders/invoices, should be nothing ordered");

    my $inv_adj_1 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice->{invoiceid},
            adjustment    => 3,
            encumber_open => 0,
            budget_id     => $budget->{budget_id},
        }
    });

    $spent = GetBudgetSpent( $budget->{budget_id} );
    $ordered = GetBudgetOrdered( $budget->{budget_id} );
    is( $spent, 0, "After adding invoice adjustment on open invoice, should be nothing spent");
    is( $ordered, 0, "After adding invoice adjustment on open invoice not encumbered, should be nothing ordered");

    my $inv_adj_2 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice->{invoiceid},
            adjustment    => 3,
            encumber_open => 1,
            budget_id     => $budget->{budget_id},
        }
    });

    $spent = GetBudgetSpent( $budget->{budget_id} );
    $ordered = GetBudgetOrdered( $budget->{budget_id} );
    is( $spent, 0, "After adding invoice adjustment on open invoice, should be nothing spent");
    is( $ordered, 3, "After adding invoice adjustment on open invoice encumbered, should be 3 ordered");

    my $invoice_2 = $builder->build({
        source => 'Aqinvoice',
        value  => {
            closedate => '2017-07-01',
        }
    });
    my $inv_adj_3 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice_2->{invoiceid},
            adjustment    => 3,
            encumber_open => 0,
            budget_id     => $budget->{budget_id},
        }
    });
    my $inv_adj_4 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice_2->{invoiceid},
            adjustment    => 3,
            encumber_open => 1,
            budget_id     => $budget->{budget_id},
        }
    });

    $spent = GetBudgetSpent( $budget->{budget_id} );
    $ordered = GetBudgetOrdered( $budget->{budget_id} );
    is( $spent, 6, "After adding invoice adjustment on closed invoice, should be 6 spent, encumber has no affect once closed");
    is( $ordered, 3, "After adding invoice adjustment on closed invoice, should still be 3 ordered");

    my $budget_2 = $builder->build({
        source => 'Aqbudget',
        value  => {
            budget_amount => 1000,
        }
    });
    my $inv_adj_5 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice->{invoiceid},
            adjustment    => 3,
            encumber_open => 1,
            budget_id     => $budget_2->{budget_id},
        }
    });
    my $inv_adj_6 = $builder->build({
        source => 'AqinvoiceAdjustment',
        value  => {
            invoiceid     => $invoice_2->{invoiceid},
            adjustment    => 3,
            encumber_open => 1,
            budget_id     => $budget_2->{budget_id},
        }
    });

    $spent = GetBudgetSpent( $budget->{budget_id} );
    $ordered = GetBudgetOrdered( $budget->{budget_id} );
    is( $spent, 6, "After adding invoice adjustment on a different budget should be 6 spent/budget unaffected");
    is( $ordered, 3, "After adding invoice adjustment on a different budget, should still be 3 ordered/budget unaffected");

};

sub _get_dependencies {
    my ($budget_hierarchy) = @_;
    my $graph;
    for my $budget (@$budget_hierarchy) {
        if ( $budget->{child} ) {
            my @sorted = sort @{ $budget->{child} };
            for my $child_id (@sorted) {
                push @{ $graph->{ $budget->{budget_name} }{children} },
                  _get_budgetname_by_id( $budget_hierarchy, $child_id );
            }
        }
        push @{ $graph->{ $budget->{budget_name} }{parents} },
          $budget->{parent_id};
    }
    return $graph;
}

sub _get_budgetname_by_id {
    my ( $budgets, $budget_id ) = @_;
    my ($budget_name) =
      map { ( $_->{budget_id} eq $budget_id ) ? $_->{budget_name} : () }
      @$budgets;
    return $budget_name;
}

# C4::Context->userenv
sub Mock_userenv {
    return $userenv;
}
