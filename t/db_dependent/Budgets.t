use Modern::Perl;
use Test::More tests => 71;

BEGIN {
    use_ok('C4::Budgets')
}
use C4::Context;
use C4::Biblio;
use C4::Bookseller;
use C4::Acquisition;
use C4::Dates;

use YAML;
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM aqbudgetperiods|);
$dbh->do(q|DELETE FROM aqbudgets|);

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

is( AddBudget(), undef, 'AddBuget without argument returns undef' );
my $budgets = GetBudgets();
is( @$budgets, 0, 'GetBudgets returns the correct number of budgets' );

$bpid = AddBudgetPeriod($my_budgetperiod);
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

my $budget_code = $my_budget->{budget_code};
my $budget_by_code = GetBudgetByCode( $budget_code );
is($budget_by_code->{budget_id}, $budget_id, "GetBudgetByCode, check id");
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
is( @$budgets, 1, 'GetBudgets returns the correct number of budget periods' );


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
my $budget_id11 = AddBudget(
    {
        budget_code      => 'budget_11',
        budget_name      => 'budget_11',
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id1,
        budget_amount    => $budget_11_total,
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

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name         => "my vendor",
        address1     => "bookseller's address",
        phone        => "0123456",
        active       => 1,
        deliverytime => 5,
    }
);

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
my $item_price = 10;
my $item_quantity = 2;
for my $infos (@order_infos) {
    for ( 1 .. $infos->{pending_quantity} ) {
        my ( undef, $ordernumber ) = C4::Acquisition::NewOrder(
            {
                basketno           => $basketno,
                biblionumber       => $biblionumber,
                budget_id          => $infos->{budget_id},
                order_internalnote => "internal note",
                order_vendornote   => "vendor note",
                quantity           => 2,
                cost               => $item_price,
                rrp                => $item_price,
                listprice          => $item_price,
                ecost              => $item_price,
                rrp                => $item_price,
                discount           => 0,
                uncertainprice     => 0,
                gstrate            => 0,
            }
        );
        push @{ $budgets{$infos->{budget_id}} }, $ordernumber;
    }
    for ( 1 .. $infos->{spent_quantity} ) {
        my ( undef, $ordernumber ) = C4::Acquisition::NewOrder(
            {
                basketno           => $basketno,
                biblionumber       => $biblionumber,
                budget_id          => $infos->{budget_id},
                order_internalnote => "internal note",
                order_vendornote   => "vendor note",
                quantity           => $item_quantity,
                cost               => $item_price,
                rrp                => $item_price,
                listprice          => $item_price,
                ecost              => $item_price,
                rrp                => $item_price,
                discount           => 0,
                uncertainprice     => 0,
                gstrate            => 0,
            }
        );
        ModReceiveOrder({
              biblionumber     => $biblionumber,
              ordernumber      => $ordernumber,
              budget_id        => $infos->{budget_id},
              quantityreceived => $item_quantity,
              cost             => $item_price,
              ecost            => $item_price,
              invoiceid        => $invoiceid,
              rrp              => $item_price,
              received_items   => [],
        } );
    }
}
is( GetBudgetHierarchySpent( $budget_id1 ), 160, "total spent for budget1 is 160" );
is( GetBudgetHierarchySpent( $budget_id11 ), 100, "total spent for budget11 is 100" );
is( GetBudgetHierarchySpent( $budget_id111 ), 20, "total spent for budget111 is 20" );

# CloneBudgetPeriod
my $budget_period_id_cloned = C4::Budgets::CloneBudgetPeriod(
    {
        budget_period_id        => $budget_period_id,
        budget_period_startdate => '2014-01-01',
        budget_period_enddate   => '2014-12-31',
    }
);

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
