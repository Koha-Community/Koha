#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 88;
use Test::MockModule;
use Test::Warn;

use C4::Context;
use Koha::DateUtils;
use DateTime::Duration;
use t::lib::Mocks;
use C4::Acquisition;
use C4::Serials;
use C4::Budgets;
use C4::Biblio;

use Koha::Acquisition::Order;
use Koha::Database;

BEGIN {
    use_ok('C4::Bookseller');
    use_ok('Koha::Acquisition::Bookseller');
}

can_ok(

    'C4::Bookseller', qw(
      AddBookseller
      DelBookseller
      GetBooksellersWithLateOrders
      ModBookseller )
);

#Start transaction
my $dbh = C4::Context->dbh;
my $database = Koha::Database->new();
my $schema = $database->schema();
$schema->storage->txn_begin();

$dbh->{RaiseError} = 1;

#Start tests
$dbh->do(q|DELETE FROM aqorders|);
$dbh->do(q|DELETE FROM aqbasket|);
$dbh->do(q|DELETE FROM aqbooksellers|);
$dbh->do(q|DELETE FROM subscription|);

#Test AddBookseller
my $count            = scalar( Koha::Acquisition::Bookseller->search() );
my $sample_supplier1 = {
    name          => 'Name1',
    address1      => 'address1_1',
    address2      => 'address1-2',
    address3      => 'address1_2',
    address4      => 'address1_2',
    postal        => 'postal1',
    phone         => 'phone1',
    accountnumber => 'accountnumber1',
    fax           => 'fax1',
    url           => 'url1',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '1.0000',
    discount      => '1.0000',
    notes         => 'notes1',
    deliverytime  => undef
};
my $sample_supplier2 = {
    name          => 'Name2',
    address1      => 'address1_2',
    address2      => 'address2-2',
    address3      => 'address3_2',
    address4      => 'address4_2',
    postal        => 'postal2',
    phone         => 'phone2',
    accountnumber => 'accountnumber2',
    fax           => 'fax2',
    url           => 'url2',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '2.0000',
    discount      => '2.0000',
    notes         => 'notes2',
    deliverytime  => 2
};

my $id_supplier1 = C4::Bookseller::AddBookseller($sample_supplier1);
my $id_supplier2 = C4::Bookseller::AddBookseller($sample_supplier2);

#my $id_bookseller3 = C4::Bookseller::AddBookseller();# NOTE : Doesn't work because the field name cannot be null

like( $id_supplier1, '/^\d+$/', "AddBookseller for supplier1 return an id" );
like( $id_supplier2, '/^\d+$/', "AddBookseller for supplier2 return an id" );
my @b = Koha::Acquisition::Bookseller->search();
is ( scalar(@b),
    $count + 2, "Supplier1 and Supplier2 have been added" );

#Test DelBookseller
my $del = C4::Bookseller::DelBookseller($id_supplier1);
is( $del, 1, "DelBookseller returns 1 - 1 supplier has been deleted " );
my $b = Koha::Acquisition::Bookseller->fetch({id => $id_supplier1});
is( $b,
    undef, "Supplier1  has been deleted - id_supplier1 $id_supplier1 doesnt exist anymore" );

#Test get bookseller
my @bookseller2 = Koha::Acquisition::Bookseller->search({name => $sample_supplier2->{name} });
is( scalar(@bookseller2), 1, "Get only  Supplier2" );
$bookseller2[0] = field_filter( $bookseller2[0] );

$sample_supplier2->{id} = $id_supplier2;
is_deeply( $bookseller2[0], $sample_supplier2,
    "Koha::Acquisition::Bookseller->search returns the right informations about $sample_supplier2" );

$id_supplier1 = C4::Bookseller::AddBookseller($sample_supplier1);
my @booksellers = Koha::Acquisition::Bookseller->search(); #NOTE :without params, it returns all the booksellers
for my $i ( 0 .. scalar(@booksellers) - 1 ) {
    $booksellers[$i] = field_filter( $booksellers[$i] );
}

$sample_supplier1->{id} = $id_supplier1;
is( scalar(@booksellers), $count + 2, "Get  Supplier1 and Supplier2" );
my @tab = ( $sample_supplier1, $sample_supplier2 );
is_deeply( \@booksellers, \@tab,
    "Returns right fields of Supplier1 and Supplier2" );

#Test basket_count
my @bookseller1 = Koha::Acquisition::Bookseller->search({name => $sample_supplier1->{name} });
is( $bookseller1[0]->basket_count, 0, 'Supplier1 has 0 basket' );
my $basketno1 =
  C4::Acquisition::NewBasket( $id_supplier1, 'authorisedby1', 'basketname1' );
my $basketno2 =
  C4::Acquisition::NewBasket( $id_supplier1, 'authorisedby2', 'basketname2' );
@bookseller1 = Koha::Acquisition::Bookseller::search({ name => $sample_supplier1->{name} });
is( $bookseller1[0]->basket_count, 2, 'Supplier1 has 2 baskets' );

#Test Koha::Acquisition::Bookseller->new using id
my $bookseller1fromid = Koha::Acquisition::Bookseller->fetch;
is( $bookseller1fromid, undef,
    "fetch returns undef if no id given" );
$bookseller1fromid = Koha::Acquisition::Bookseller->fetch({ id => $id_supplier1});
$bookseller1fromid = field_filter($bookseller1fromid);
is_deeply( $bookseller1fromid, $sample_supplier1,
    "Get Supplier1 (fetch a bookseller by id)" );

#Test basket_count
$bookseller1fromid = Koha::Acquisition::Bookseller->fetch({ id => $id_supplier1});
is( $bookseller1fromid->basket_count, 2, 'Supplier1 has 2 baskets' );

#Test subscription_count
my $dt_today    = dt_from_string;
my $today       = output_pref({ dt => $dt_today, dateformat => 'iso', timeformat => '24hr', dateonly => 1 });

my $dt_today1 = dt_from_string;
my $dur5 = DateTime::Duration->new( days => -5 );
$dt_today1->add_duration($dur5);
my $daysago5 = output_pref({ dt => $dt_today1, dateformat => 'iso', timeformat => '24hr', dateonly => 1 });

my $budgetperiod = C4::Budgets::AddBudgetPeriod({
    budget_period_startdate   => $daysago5,
    budget_period_enddate     => $today,
    budget_period_description => "budget desc"
});
my $id_budget = AddBudget({
    budget_code        => "CODE",
    budget_amount      => "123.132",
    budget_name        => "Budgetname",
    budget_notes       => "This is a note",
    budget_period_id   => $budgetperiod
});
my $bib = MARC::Record->new();
$bib->append_fields(
    MARC::Field->new('245', ' ', ' ', a => 'Journal of ethnology'),
    MARC::Field->new('500', ' ', ' ', a => 'bib notes'),
);
my ($biblionumber, $biblioitemnumber) = AddBiblio($bib, '');
$bookseller1fromid = Koha::Acquisition::Bookseller->fetch({ id => $id_supplier1 });
is( $bookseller1fromid->subscription_count,
    0, 'Supplier1 has 0 subscription' );

my $id_subscription1 = NewSubscription(
    undef,      'BRANCH2',     $id_supplier1, undef, $id_budget, $biblionumber,
    '01-01-2013',undef, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "subscription notes",undef, '01-01-2013', undef, undef,
    undef, 'CALL ABC',  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-11-30', 0
);

my @subscriptions = SearchSubscriptions({biblionumber => $biblionumber});
is($subscriptions[0]->{publicnotes}, 'subscription notes', 'subscription search results include public notes (bug 10689)');

my $id_subscription2 = NewSubscription(
    undef,      'BRANCH2',     $id_supplier1, undef, $id_budget, $biblionumber,
    '01-01-2013',undef, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "subscription notes",undef, '01-01-2013', undef, undef,
    undef, 'CALL DEF',  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-07-31', 0
);

$bookseller1fromid = Koha::Acquisition::Bookseller->fetch({ id => $id_supplier1 });
is( $bookseller1fromid->subscription_count,
    2, 'Supplier1 has 2 subscriptions' );

#Test ModBookseller
$sample_supplier2 = {
    id            => $id_supplier2,
    name          => 'Name2 modified',
    address1      => 'address1_2 modified',
    address2      => 'address2-2 modified',
    address3      => 'address3_2 modified',
    address4      => 'address4_2 modified',
    postal        => 'postal2 modified',
    phone         => 'phone2 modified',
    accountnumber => 'accountnumber2 modified',
    fax           => 'fax2 modified',
    url           => 'url2 modified',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '2.0000 ',
    discount      => '2.0000',
    notes         => 'notes2 modified',
    deliverytime  => 2,
};

my $modif1 = C4::Bookseller::ModBookseller();
is( $modif1, undef,
    "ModBookseller returns undef if no params given - Nothing happened" );
$modif1 = C4::Bookseller::ModBookseller($sample_supplier2);
is( $modif1, 1, "ModBookseller modifies only the supplier2" );
is( scalar( Koha::Acquisition::Bookseller->search ),
    $count + 2, "Supplier2 has been modified - Nothing added" );

$modif1 = C4::Bookseller::ModBookseller(
    {
        id   => -1,
        name => 'name3'
    }
);
#is( $modif1, '0E0',
#    "ModBookseller returns OEO if the id doesnt exist - Nothing modified" );

#Test GetBooksellersWithLateOrders
#Add 2 suppliers
my $sample_supplier3 = {
    name          => 'Name3',
    address1      => 'address1_3',
    address2      => 'address1-3',
    address3      => 'address1_3',
    address4      => 'address1_3',
    postal        => 'postal3',
    phone         => 'phone3',
    accountnumber => 'accountnumber3',
    fax           => 'fax3',
    url           => 'url3',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '3.0000',
    discount      => '3.0000',
    notes         => 'notes3',
    deliverytime  => 3
};
my $sample_supplier4 = {
    name          => 'Name4',
    address1      => 'address1_4',
    address2      => 'address1-4',
    address3      => 'address1_4',
    address4      => 'address1_4',
    postal        => 'postal4',
    phone         => 'phone4',
    accountnumber => 'accountnumber4',
    fax           => 'fax4',
    url           => 'url4',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '3.0000',
    discount      => '3.0000',
    notes         => 'notes3',
};
my $id_supplier3 = C4::Bookseller::AddBookseller($sample_supplier3);
my $id_supplier4 = C4::Bookseller::AddBookseller($sample_supplier4);

#Add 2 baskets
my $basketno3 =
  C4::Acquisition::NewBasket( $id_supplier3, 'authorisedby3', 'basketname3',
    'basketnote3' );
my $basketno4 =
  C4::Acquisition::NewBasket( $id_supplier4, 'authorisedby4', 'basketname4',
    'basketnote4' );

#Modify the basket to add a close date
my $basket1info = {
    basketno     => $basketno1,
    closedate    => $today,
    booksellerid => $id_supplier1
};

my $basket2info = {
    basketno     => $basketno2,
    closedate    => $daysago5,
    booksellerid => $id_supplier2
};

my $dt_today2 = dt_from_string;
my $dur10 = DateTime::Duration->new( days => -10 );
$dt_today2->add_duration($dur10);
my $daysago10 = output_pref({ dt => $dt_today2, dateformat => 'iso', timeformat => '24hr', dateonly => 1 });
my $basket3info = {
    basketno  => $basketno3,
    closedate => $daysago10,
};

my $basket4info = {
    basketno  => $basketno4,
    closedate => $today,
};
ModBasket($basket1info);
ModBasket($basket2info);
ModBasket($basket3info);
ModBasket($basket4info);

#Add 1 subscription
my $id_subscription3 = NewSubscription(
    undef,      "BRANCH1",     $id_supplier1, undef, $id_budget, $biblionumber,
    '01-01-2013',undef, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "subscription notes",undef, '01-01-2013', undef, undef,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          'LOCA',         '2013-12-31', 0
);

@subscriptions = SearchSubscriptions({expiration_date => '2013-12-31'});
is(scalar(@subscriptions), 3, 'search for subscriptions by expiration date');
@subscriptions = SearchSubscriptions({expiration_date => '2013-08-15'});
is(scalar(@subscriptions), 1, 'search for subscriptions by expiration date');
@subscriptions = SearchSubscriptions({callnumber => 'CALL'});
is(scalar(@subscriptions), 2, 'search for subscriptions by call number');
@subscriptions = SearchSubscriptions({callnumber => 'DEF'});
is(scalar(@subscriptions), 1, 'search for subscriptions by call number');
@subscriptions = SearchSubscriptions({location => 'LOCA'});
is(scalar(@subscriptions), 1, 'search for subscriptions by location');

#Add 4 orders
my $order1 = Koha::Acquisition::Order->new(
    {
        basketno         => $basketno1,
        quantity         => 24,
        biblionumber     => $biblionumber,
        budget_id        => $id_budget,
        entrydate        => '01-01-2013',
        currency         => 'EUR',
        notes            => "This is a note1",
        gstrate          => 0.0500,
        orderstatus      => 1,
        subscriptionid   => $id_subscription1,
        quantityreceived => 2,
        rrp              => 10,
        ecost            => 10,
        datereceived     => '01-06-2013'
    }
)->insert;
my $ordernumber1 = $order1->{ordernumber};

my $order2 = Koha::Acquisition::Order->new(
    {
        basketno       => $basketno2,
        quantity       => 20,
        biblionumber   => $biblionumber,
        budget_id      => $id_budget,
        entrydate      => '01-01-2013',
        currency       => 'EUR',
        notes          => "This is a note2",
        gstrate        => 0.0500,
        orderstatus    => 1,
        subscriptionid => $id_subscription2,
        rrp            => 10,
        ecost          => 10,
    }
)->insert;
my $ordernumber2 = $order2->{ordernumber};

my $order3 = Koha::Acquisition::Order->new(
    {
        basketno       => $basketno3,
        quantity       => 20,
        biblionumber   => $biblionumber,
        budget_id      => $id_budget,
        entrydate      => '02-02-2013',
        currency       => 'EUR',
        notes          => "This is a note3",
        gstrate        => 0.0500,
        orderstatus    => 2,
        subscriptionid => $id_subscription3,
        rrp            => 11,
        ecost          => 11,
    }
)->insert;
my $ordernumber3 = $order3->{ordernumber};

my $order4 = Koha::Acquisition::Order->new(
    {
        basketno         => $basketno4,
        quantity         => 20,
        biblionumber     => $biblionumber,
        budget_id        => $id_budget,
        entrydate        => '02-02-2013',
        currency         => 'EUR',
        notes            => "This is a note3",
        gstrate          => 0.0500,
        orderstatus      => 2,
        subscriptionid   => $id_subscription3,
        rrp              => 11,
        ecost            => 11,
        quantityreceived => 20
    }
)->insert;
my $ordernumber4 = $order4->{ordernumber};

#Test cases:
# Sample datas :
#   Supplier1: delivery -> undef Basket1 : closedate -> today
#   Supplier2: delivery -> 2     Basket2 : closedate -> $daysago5
#   Supplier3: delivery -> 3     Basket3 : closedate -> $daysago10
#Case 1 : Without parameters:
#   quantityreceived < quantity AND rrp <> 0 AND ecost <> 0 AND quantity - COALESCE(quantityreceived,0) <> 0 AND closedate IS NOT NULL -LATE-
#   datereceived !null AND rrp <> 0 AND ecost <> 0 AND quantity - COALESCE(quantityreceived,0) <> 0 AND closedate IS NOT NULL -LATE-
#   datereceived !null AND rrp <> 0 AND ecost <> 0 AND quantity - COALESCE(quantityreceived,0) <> 0 AND closedate IS NOT NULL -LATE-
#   quantityreceived = quantity -NOT LATE-
my %suppliers = C4::Bookseller::GetBooksellersWithLateOrders();
ok( exists( $suppliers{$id_supplier1} ), "Supplier1 has late orders" );
ok( exists( $suppliers{$id_supplier2} ), "Supplier2 has late orders" );
ok( exists( $suppliers{$id_supplier3} ), "Supplier3 has late orders" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" )
  ;    # Quantity = quantityreceived

#Case 2: With $delay = 4
#    today + 0 > now-$delay -NOT LATE-
#    (today-5) + 2   <= now() - $delay -NOT LATE-
#    (today-10) + 3  <= now() - $delay -LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers = C4::Bookseller::GetBooksellersWithLateOrders( 4, undef, undef );
isnt( exists( $suppliers{$id_supplier1} ),
    1, "Supplier1 has late orders but  today  > now() - 4 days" );
isnt( exists( $suppliers{$id_supplier2} ),
    1, "Supplier2 has late orders and $daysago5 <= now() - (4 days+2)" );
ok( exists( $suppliers{$id_supplier3} ),
    "Supplier3 has late orders and $daysago10  <= now() - (4 days+3)" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 3: With $delay = -1
my $bslo;
warning_like
  { $bslo = C4::Bookseller::GetBooksellersWithLateOrders( -1, undef, undef ) }
    qr/^WARNING: GetBooksellerWithLateOrders is called with a negative value/,
    "GetBooksellerWithLateOrders prints a warning on negative values";

is( $bslo, undef, "-1 is a wrong value for a delay" );

#Case 4: With $delay = 0
#    today  == now-0 -LATE- (if no deliverytime or deliverytime == 0)
#    today-5   <= now() - $delay+2 -LATE-
#    today-10  <= now() - $delay+3 -LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers = C4::Bookseller::GetBooksellersWithLateOrders( 0, undef, undef );

ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders but $today == now() - 0 days" )
  ;
ok( exists( $suppliers{$id_supplier2} ),
    "Supplier2 has late orders and $daysago5 <= now() - 2" );
ok( exists( $suppliers{$id_supplier3} ),
    "Supplier3 has late orders and $daysago10 <= now() - 3" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 5 : With $estimateddeliverydatefrom = today-4
#    today >= today-4 -NOT LATE-
#    (today-5)+ 2 days >= today-4  -LATE-
#    (today-10) + 3 days < today-4   -NOT LATE-
#    quantityreceived = quantity -NOT LATE-
my $dt_today3 = dt_from_string;
my $dur4 = DateTime::Duration->new( days => -4 );
$dt_today3->add_duration($dur4);
my $daysago4 =  output_pref({ dt => $dt_today3, dateformat => 'iso', timeformat => '24hr', dateonly => 1 });
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago4, undef );

ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders and $today >= $daysago4 -deliverytime undef" );
ok( exists( $suppliers{$id_supplier2} ),
    "Supplier2 has late orders and $daysago5 + 2 days >= $daysago4 " );
isnt( exists( $suppliers{$id_supplier3} ),
    1, "Supplier3 has late orders and $daysago10 + 5 days < $daysago4 " );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 6: With $estimateddeliverydatefrom =today-10 and $estimateddeliverydateto = today - 5
#    $daysago10<$daysago5<today -NOT LATE-
#    $daysago10<$daysago5<$daysago5 +2 -NOT lATE-
#    $daysago10<$daysago10 +3 <$daysago5 -LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers = C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago10,
    $daysago5 );
isnt( exists( $suppliers{$id_supplier1} ),
    1, "Supplier1 has late orders but $daysago10 < $daysago5 < $today" );
isnt(
    exists( $suppliers{$id_supplier2} ),
    1,
    "Supplier2 has late orders but $daysago10 < $daysago5 < $daysago5+2"
);
ok(
    exists( $suppliers{$id_supplier3} ),
"Supplier3 has late orders and $daysago10 <= $daysago10 +3 <= $daysago5"
);
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 7: With $estimateddeliverydateto = today-5
#    $today >= $daysago5  -NOT LATE-
#    $daysago5 + 2 days  > $daysago5 -NOT LATE-
#    $daysago10 + 3  <+ $daysago5  -LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, undef, $daysago5 );
isnt( exists( $suppliers{$id_supplier1} ),
    1,
    "Supplier1 has late orders but $today >= $daysago5 - deliverytime undef" );
isnt( exists( $suppliers{$id_supplier2} ),
    1, "Supplier2 has late orders but  $daysago5 + 2 days  > $daysago5 " );
ok( exists( $suppliers{$id_supplier3} ),
    "Supplier3 has late orders and $daysago10 + 3  <= $daysago5" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Test with $estimateddeliverydatefrom and  $estimateddeliverydateto and $delay
#Case 8 :With $estimateddeliverydatefrom = 2013-07-05 and  $estimateddeliverydateto = 2013-07-08 and $delay =5
#    $daysago4<today<=$today and $today<now()-3  -NOT LATE-
#    $daysago4 < $daysago5 + 2days <= today and $daysago5 <= now()-3+2 days -LATE-
#    $daysago4 > $daysago10 + 3days < today and $daysago10 <= now()-3+3 days -NOT LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( 3, $daysago4, $today );
isnt(
    exists( $suppliers{$id_supplier1} ),
    1,
    "Supplier1 has late orders but $daysago4<today<=$today and $today<now()-3"
);
ok(
    exists( $suppliers{$id_supplier2} ),
"Supplier2 has late orders and $daysago4 < $daysago5 + 2days <= today and $daysago5 <= now()-3+2 days"
);
isnt(
    exists( $suppliers{$id_supplier3} ),
"Supplier3 has late orders but $daysago4 > $daysago10 + 3days < today and $daysago10 <= now()-3+3 days"
);
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 9 :With $estimateddeliverydatefrom = $daysago5  and $delay = 3
#   $today < $daysago5 and $today > $today-5 -NOT LATE-
#   $daysago5 + 2 days >= $daysago5  and $daysago5 < today - 3+2 -LATE-
#   $daysago10 + 3 days < $daysago5 and $daysago10 < today -3+2-NOT LATE-
#   quantityreceived = quantity -NOT LATE-
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( 3, $daysago5, undef );
isnt( exists( $suppliers{$id_supplier1} ),
    1, "$today < $daysago10 and $today > $today-3" );
ok(
    exists( $suppliers{$id_supplier2} ),
"Supplier2 has late orders and $daysago5 + 2 days >= $daysago5  and $daysago5 < today - 3+2"
);
isnt(
    exists( $suppliers{$id_supplier3} ),
    1,
"Supplier2 has late orders but $daysago10 + 3 days < $daysago5 and $daysago10 < today -3+2 "
);
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Test with $estimateddeliverydateto  and $delay
#Case 10:With $estimateddeliverydateto = $daysago5 and $delay = 5
#    today > $daysago5 today > now() -5 -NOT LATE-
#    $daysago5 + 2 days > $daysago5  and $daysago5 > now() - 2+5 days -NOT LATE-
#    $daysago10 + 3 days <= $daysago5 and $daysago10 <= now() - 3+5 days -LATE-
#    quantityreceived = quantity -NOT LATE-
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( 5, undef, $daysago5 );
isnt( exists( $suppliers{$id_supplier1} ),
    1, "Supplier2 has late orders but today > $daysago5 today > now() -5" );
isnt(
    exists( $suppliers{$id_supplier2} ),
    1,
"Supplier2 has late orders but $daysago5 + 2 days > $daysago5  and $daysago5 > now() - 2+5 days"
);
ok(
    exists( $suppliers{$id_supplier3} ),
"Supplier2 has late orders and $daysago10 + 3 days <= $daysago5 and $daysago10 <= now() - 3+5 days "
);
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 11: With $estimateddeliverydatefrom =today-10 and $estimateddeliverydateto = today - 10
#    $daysago10==$daysago10==$daysago10 -NOT LATE-
#    $daysago10==$daysago10<$daysago5+2-NOT lATE-
#    $daysago10==$daysago10 <$daysago10+3-LATE-
#    quantityreceived = quantity -NOT LATE-

#Basket1 closedate -> $daysago10
$basket1info = {
    basketno  => $basketno1,
    closedate => $daysago10,
};
ModBasket($basket1info);
%suppliers = C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago10,
    $daysago10 );
ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders and $daysago10==$daysago10==$daysago10 " )
  ;
isnt( exists( $suppliers{$id_supplier2} ),
    1,
    "Supplier2 has late orders but $daysago10==$daysago10<$daysago5+2" );
isnt( exists( $suppliers{$id_supplier3} ),
    1,
    "Supplier3 has late orders but $daysago10==$daysago10 <$daysago10+3" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 12: closedate == $estimateddeliverydatefrom =today-10
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago10, undef );
ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders and $daysago10==$daysago10 " );

#Case 13: closedate == $estimateddeliverydateto =today-10
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, undef, $daysago10 );
ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders and $daysago10==$daysago10 " )
  ;

C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(0,0,0,'firstname','surname', 'BRANCH1', 'Library 1', 0, '', '');
my $userenv = C4::Context->userenv;

my $module = Test::MockModule->new('C4::Auth');
$module->mock(
    'haspermission',
    sub {
        # simulate user that has serials permissions but
        # NOT superserials
        my ($userid, $flagsrequired) = @_;
        return 0 if 'superserials' eq ($flagsrequired->{serials} // 0);
        return exists($flagsrequired->{serials});
    }
);

t::lib::Mocks::mock_preference('IndependentBranches', 0);
@subscriptions = SearchSubscriptions({expiration_date => '2013-12-31'});
is(
    scalar(grep { !$_->{cannotdisplay} } @subscriptions ),
    3,
    'ordinary user can see all subscriptions with IndependentBranches off'
);

t::lib::Mocks::mock_preference('IndependentBranches', 1);
@subscriptions = SearchSubscriptions({expiration_date => '2013-12-31'});
is(
    scalar(grep { !$_->{cannotdisplay} } @subscriptions ),
    1,
    'ordinary user can see only their library\'s subscriptions with IndependentBranches on'
);

# don the cape and turn into Superlibrarian!
C4::Context->set_userenv(0,0,0,'firstname','surname', 'BRANCH1', 'Library 1', 1, '', '');
@subscriptions = SearchSubscriptions({expiration_date => '2013-12-31'});
is(
    scalar(grep { !$_->{cannotdisplay} } @subscriptions ),
    3,
    'superlibrarian can see all subscriptions with IndependentBranches on (bug 12048)'
);
#Test contact editing
my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name     => "my vendor",
        address1 => "bookseller's address",
        phone    => "0123456",
        active   => 1
    },
    [
        { name => 'John Smith',  phone => '0123456x1' },
        { name => 'Leo Tolstoy', phone => '0123456x2' },
    ]
);

@booksellers = Koha::Acquisition::Bookseller->search({ name => 'my vendor' });
ok(
    ( grep { $_->{'id'} == $booksellerid } @booksellers ),
    'Koha::Acquisition::Bookseller->search returns correct record when passed a name'
);

my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
is( $bookseller->{'id'}, $booksellerid, 'Retrieved desired record' );
is( $bookseller->{'phone'}, '0123456', 'New bookseller has expected phone' );
my $contacts = $bookseller->contacts;
is( ref $bookseller->contacts,
    'ARRAY', 'Koha::Acquisition::Bookseller->fetch returns arrayref of contacts' );
is(
    ref $bookseller->{'contacts'}->[0],
    'C4::Bookseller::Contact',
    'First contact is a contact object'
);
is( $bookseller->{'contacts'}->[0]->phone,
    '0123456x1', 'Contact has expected phone number' );
is( scalar @{ $bookseller->{'contacts'} }, 2, 'Saved two contacts' );

pop @{ $bookseller->{'contacts'} };
$bookseller->{'name'} = 'your vendor';
$bookseller->{'contacts'}->[0]->phone('654321');
C4::Bookseller::ModBookseller($bookseller);

$bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
$contacts = $bookseller->contacts;
is( $bookseller->{'name'}, 'your vendor',
    'Successfully changed name of vendor' );
is( $contacts->[0]->phone,
    '654321',
    'Successfully changed contact phone number by modifying bookseller hash' );
is( scalar @$contacts,
    1, 'Only one contact after modification' );

C4::Bookseller::ModBookseller( $bookseller,
    [ { name => 'John Jacob Jingleheimer Schmidt' } ] );

$bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
$contacts = $bookseller->contacts;
is(
    $contacts->[0]->name,
    'John Jacob Jingleheimer Schmidt',
    'Changed name of contact'
);
is( $contacts->[0]->phone,
    undef, 'Removed phone number from contact' );
is( scalar @$contacts,
    1, 'Only one contact after modification' );

#End transaction
$schema->storage->txn_rollback();

#field_filter filters the useless fields or foreign keys
#NOTE: all the fields of aqbookseller arent considered
#returns a cleaned structure
sub field_filter {
    my ($struct) = @_;

    for my $field (
        'bookselleremail', 'booksellerfax',
        'booksellerurl',   'othersupplier',
        'currency',        'invoiceprice',
        'listprice',       'contacts'
      )
    {

        if ( grep { /^$field$/ } keys %$struct ) {
            delete $struct->{$field};
        }
    }
    return $struct;
}
