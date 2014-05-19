use Modern::Perl;
use Test::More tests => 25;

BEGIN {use_ok('C4::Budgets') }
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
my $bpid;
my $budgetperiod;
my $active_period;
my $mod_status;
my $del_status;
ok($bpid=AddBudgetPeriod(
						{ budget_period_startdate	=> '2008-01-01'
						, budget_period_enddate		=> '2008-12-31'
						, budget_description		=> "MAPERI"}),
	"AddBudgetPeriod with iso dates OK");

ok($budgetperiod=GetBudgetPeriod($bpid),
	"GetBudgetPeriod($bpid) returned ".Dump($budgetperiod));
ok(!GetBudgetPeriod(0) ,"GetBudgetPeriod(0) returned undef : noactive BudgetPeriod");
$$budgetperiod{budget_period_active}=1;
ok($mod_status=ModBudgetPeriod($budgetperiod),"ModBudgetPeriod OK");
ok($active_period=GetBudgetPeriod(0),"GetBudgetPeriod(0) returned".Dump($active_period));
ok(scalar(GetBudgetPeriods())>0,"GetBudgetPeriods OK");#Should at least return the Budget inserted
ok($del_status=DelBudgetPeriod($bpid),"DelBudgetPeriod returned $del_status");

#
# Budget  :
#

# Add A budget Period
if (C4::Context->preference('dateformat') eq "metric"){
ok($bpid=AddBudgetPeriod(
						{ budget_period_startdate	=>'01-01-2008'
						, budget_period_enddate		=>'31-12-2008'
						, budget_description		=>"MAPERI"}),
	"AddBudgetPeriod returned $bpid");
} elsif (C4::Context->preference('dateformat') eq "us"){
ok($bpid=AddBudgetPeriod(
						{ budget_period_startdate	=>'01-01-2008'
						, budget_period_enddate		=>'12-31-2008'
						, budget_description		=>"MAPERI"}),
	"AddBudgetPeriod returned $bpid");
}
else{
ok($bpid=AddBudgetPeriod(
						{budget_period_startdate=>'2008-01-01'
						,budget_period_enddate	=>'2008-12-31'
						,budget_description		=>"MAPERI"
						}),
	"AddBudgetPeriod returned $bpid");

}
my $budget_id;
ok($budget_id=AddBudget(
						{   budget_code 		=> "ABCD"
							, budget_amount		=> "123.132"
							, budget_name		=> "Périodiques"
							, budget_notes		=> "This is a note"
							, budget_description=> "Serials"
							, budget_active		=> 1
							, budget_period_id	=> $bpid
						}
					   ),
	"AddBudget returned $budget_id");
#budget_code            | varchar(30)   | YES  |     | NULL              |       | 
#| budget_amount          | decimal(28,6) | NO   |     | 0.000000          |       | 
#| budget_id              | int(11)       | NO   | PRI | NULL              |       | 
#| budget_branchcode      | varchar(10)   | YES  |     | NULL              |       | 
#| budget_parent_id       | int(11)       | YES  |     | NULL              |       | 
#| budget_name            | varchar(80)   | YES  |     | NULL              |       | 
#| budget_encumb          | decimal(28,6) | YES  |     | 0.000000          |       | 
#| budget_expend          | decimal(28,6) | YES  |     | 0.000000          |       | 
#| budget_notes           | mediumtext    | YES  |     | NULL              |       | 
#| timestamp              | timestamp     | NO   |     | CURRENT_TIMESTAMP |       | 
#| budget_period_id       | int(11)       | YES  | MUL | NULL              |       | 
#| sort1_authcat          | varchar(80)   | YES  |     | NULL              |       | 
#| sort2_authcat          | varchar(80)   | YES  |     | NULL              |       | 
#| budget_owner_id        | int(11)       | YES  |     | NULL              |       | 
#| budget_permission      | int(1)        | YES  |     | 0                 |       | 

my $budget;
ok($budget=GetBudget($budget_id) ,"GetBudget OK");
$budget_id = $budget->{budget_id};
$$budget{budget_permission}=1;
ok($mod_status=ModBudget($budget),"ModBudget OK");
ok(GetBudgets()>0,
	"GetBudgets OK");
ok(GetBudgets({budget_period_id=>$bpid})>0,
	"GetBudgets With Filter OK");
ok(GetBudgets({budget_period_id=>$bpid},[{"budget_name"=>0}])>0,
	"GetBudgets With Order OK");
ok(GetBudgets({budget_period_id=>GetBudgetPeriod($bpid)->{budget_period_id}},[{"budget_name"=>0}])>0,
	"GetBudgets With Order 
	Getting Active budgetPeriod OK");

my $budget_name = GetBudgetName( $budget_id );
is($budget_name, $budget->{budget_name}, "Test the GetBudgetName routine");

my $budget_code = $budget->{budget_code};
my $budget_by_code = GetBudgetByCode( $budget_code );
is($budget_by_code->{budget_id}, $budget_id, "GetBudgetByCode, check id");
is($budget_by_code->{budget_notes}, 'This is a note', "GetBudgetByCode, check notes");

my $second_budget_id;
ok($second_budget_id=AddBudget(
                        {   budget_code         => "ZZZZ",
                            budget_amount       => "500.00",
                            budget_name     => "Art",
                            budget_notes        => "This is a note",
                            budget_description=> "Art",
                            budget_active       => 1,
                            budget_period_id    => $bpid,
                        }
                       ),
    "AddBudget returned $second_budget_id");

my $budgets = GetBudgets({ budget_period_id => $bpid});
ok($budgets->[0]->{budget_name} lt $budgets->[1]->{budget_name}, 'default sort order for GetBudgets is by name');

ok($del_status=DelBudget($budget_id),
    "DelBudget returned $del_status");

# GetBudgetHierarchySpent and GetBudgetHierarchyOrdered
my $budget_period_total = 10_000;
my $budget_1_total = 1_000;
my $budget_11_total = 100;
my $budget_111_total = 50;
my $budget_12_total = 100;
my $budget_2_total = 2_000;

my $budget_period_id = AddBudgetPeriod(
    {
        budget_period_startdate => '2013-01-01',
        budget_period_enddate   => '2014-12-31',
        budget_description      => 'Budget Period',
        budget_period_active    => 1,
        budget_period_total     => $budget_period_total,
    }
);
my $budget_id1 = AddBudget(
    {
        budget_code      => 'budget_1',
        budget_name      => 'budget_1',
        budget_active    => 1,
        budget_period_id => $budget_period_id,
        budget_parent_id => undef,
        budget_amount    => $budget_1_total,
    }
);
my $budget_id2 = AddBudget(
    {
        budget_code      => 'budget_2',
        budget_name      => 'budget_2',
        budget_active    => 1,
        budget_period_id => $budget_period_id,
        budget_parent_id => undef,
        budget_amount    => $budget_2_total,
    }
);
my $budget_id11 = AddBudget(
    {
        budget_code      => 'budget_11',
        budget_name      => 'budget_11',
        budget_active    => 1,
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id1,
        budget_amount    => $budget_11_total,
    }
);
my $budget_id12 = AddBudget(
    {
        budget_code      => 'budget_12',
        budget_name      => 'budget_12',
        budget_active    => 1,
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id1,
        budget_amount    => $budget_12_total,
    }
);
my $budget_id111 = AddBudget(
    {
        budget_code      => 'budget_111',
        budget_name      => 'budget_111',
        budget_active    => 1,
        budget_period_id => $budget_period_id,
        budget_parent_id => $budget_id11,
        owner_id         => 1,
        budget_amount    => $budget_111_total,
    }
);
my $budget_id21 = AddBudget(
    {
        budget_code      => 'budget_21',
        budget_name      => 'budget_21',
        budget_active    => 1,
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
