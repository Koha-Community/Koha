#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 54;
use C4::Context;
use Koha::DateUtils;
use DateTime::Duration;
use C4::Acquisition;
use C4::Serials;
use C4::Budgets;
use C4::Biblio;

BEGIN {
    use_ok('C4::Bookseller');
}

can_ok(

    'C4::Bookseller', qw(
      AddBookseller
      DelBookseller
      GetBookSeller
      GetBookSellerFromId
      GetBooksellersWithLateOrders
      ModBookseller )
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

#Start tests
$dbh->do(q|DELETE FROM aqorders|);
$dbh->do(q|DELETE FROM aqbasket|);
$dbh->do(q|DELETE FROM aqbooksellers|);
#Test AddBookseller
my $count            = scalar( C4::Bookseller::GetBookSeller('') );
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
    contact       => 'contact1',
    contpos       => 'contpos1',
    contphone     => 'contphone1',
    contfax       => 'contefax1',
    contaltphone  => 'contaltphone1',
    contemail     => 'contemail1',
    contnotes     => 'contnotes1',
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
    contact       => 'contact2',
    contpos       => 'contpos2',
    contphone     => 'contphone2',
    contfax       => 'contefax2',
    contaltphone  => 'contaltphone2',
    contemail     => 'contemail2',
    contnotes     => 'contnotes2',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '2.0000',
    discount      => '2.0000',
    notes         => 'notes2',
    deliverytime  => 2,
};

my $id_supplier1 = C4::Bookseller::AddBookseller($sample_supplier1);
my $id_supplier2 = C4::Bookseller::AddBookseller($sample_supplier2);

#my $id_bookseller3 = C4::Bookseller::AddBookseller();# NOTE : Doesn't work because the field name cannot be null

like( $id_supplier1, '/^\d+$/', "AddBookseller for supplier1 return an id" );
like( $id_supplier2, '/^\d+$/', "AddBookseller for supplier2 return an id" );
is( scalar( C4::Bookseller::GetBookSeller('') ),
    $count + 2, "Supplier1 and Supplier2 have been added" );

#Test DelBookseller
my $del = C4::Bookseller::DelBookseller($id_supplier1);
is( $del, 1, "DelBookseller returns 1 - 1 supplier has been deleted " );
is( C4::Bookseller::GetBookSellerFromId($id_supplier1),
    undef, "Supplier1  has been deleted - id_supplier1 doesnt exist anymore" );

#Test GetBookSeller
my @bookseller2 = C4::Bookseller::GetBookSeller( $sample_supplier2->{name} );
is( scalar(@bookseller2), 1, "Get only  Supplier2" );
$bookseller2[0] = field_filter( $bookseller2[0] );
delete $bookseller2[0]->{basketcount};

$sample_supplier2->{id} = $id_supplier2;
is_deeply( $bookseller2[0], $sample_supplier2,
    "GetBookSeller returns the right informations about $sample_supplier2" );

$id_supplier1 = C4::Bookseller::AddBookseller($sample_supplier1);
my @booksellers = C4::Bookseller::GetBookSeller('')
  ;    #NOTE :without params, it returns all the booksellers
for my $i ( 0 .. scalar(@booksellers) - 1 ) {
    $booksellers[$i] = field_filter( $booksellers[$i] );
    delete $booksellers[$i]->{basketcount};
}

$sample_supplier1->{id} = $id_supplier1;
is( scalar(@booksellers), $count + 2, "Get  Supplier1 and Supplier2" );
my @tab = ( $sample_supplier1, $sample_supplier2 );
is_deeply( \@booksellers, \@tab,
    "Returns right fields of Supplier1 and Supplier2" );

#Test basketcount
my @bookseller1 = C4::Bookseller::GetBookSeller( $sample_supplier1->{name} );
#FIXME : if there is 0 basket, GetBookSeller returns 1 as basketcount
#is( $bookseller1[0]->{basketcount}, 0, 'Supplier1 has 0 basket' );
my $sample_basket1 =
  C4::Acquisition::NewBasket( $id_supplier1, 'authorisedby1', 'basketname1' );
my $sample_basket2 =
  C4::Acquisition::NewBasket( $id_supplier1, 'authorisedby2', 'basketname2' );
@bookseller1 = C4::Bookseller::GetBookSeller( $sample_supplier1->{name} );
is( $bookseller1[0]->{basketcount}, 2, 'Supplier1 has 2 baskets' );

#Test GetBookSellerFromId
my $bookseller1fromid = C4::Bookseller::GetBookSellerFromId();
is( $bookseller1fromid, undef,
    "GetBookSellerFromId returns undef if no id given" );
$bookseller1fromid = C4::Bookseller::GetBookSellerFromId($id_supplier1);
$bookseller1fromid = field_filter($bookseller1fromid);
delete $bookseller1fromid->{basketcount};
delete $bookseller1fromid->{subscriptioncount};
is_deeply( $bookseller1fromid, $sample_supplier1,
    "Get Supplier1 (GetBookSellerFromId)" );

#Test basketcount
$bookseller1fromid = C4::Bookseller::GetBookSellerFromId($id_supplier1);
is( $bookseller1fromid->{basketcount}, 2, 'Supplier1 has 2 baskets' );

#Test subscriptioncount
my $dt_today    = dt_from_string;
my $today       = output_pref( $dt_today, 'iso', '24hr', 1 );

my $dt_today1 = dt_from_string;
my $dur5 = DateTime::Duration->new( days => -5 );
$dt_today1->add_duration($dur5);
my $daysago5 = output_pref( $dt_today1, 'iso', '24hr', 1 );

my $budgetperiod = C4::Budgets::AddBudgetPeriod({
    budget_period_startdate => $daysago5,
    budget_period_enddate   => $today,
    budget_description      => "budget desc"
});
my $id_budget = AddBudget({
    budget_code        => "CODE",
    budget_amount      => "123.132",
    budget_name        => "Budgetname",
    budget_notes       => "This is a note",
    budget_description => "BudgetDescription",
    budget_active      => 1,
    budget_period_id   => $budgetperiod
});
my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
$bookseller1fromid = C4::Bookseller::GetBookSellerFromId($id_supplier1);
is( $bookseller1fromid->{subscriptioncount},
    0, 'Supplier1 has 0 subscription' );
my $id_subscription1 = C4::Serials::NewSubscription(
    undef,      "",            $id_supplier1, undef,
    $id_budget, $biblionumber, '01-01-2013',  undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         1,
    "notes",    undef,         undef,         undef,
    undef,      undef,         undef,         0,
    "intnotes", 0,             undef,         undef,
    0,          undef,         '31-12-2013',
);
my $id_subscription2 = C4::Serials::NewSubscription(
    undef,      "",            $id_supplier1, undef,
    $id_budget, $biblionumber, '01-01-2013',  undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         1,
    "notes",    undef,         undef,         undef,
    undef,      undef,         undef,         0,
    "intnotes", 0,             undef,         undef,
    0,          undef,         '31-12-2013',
);
$bookseller1fromid = C4::Bookseller::GetBookSellerFromId($id_supplier1);
is( $bookseller1fromid->{subscriptioncount},
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
    contact       => 'contact2 modified',
    contpos       => 'contpos2 modified',
    contphone     => 'contphone2 modified',
    contfax       => 'contefax2 modified',
    contaltphone  => 'contaltphone2 modified',
    contemail     => 'contemail2 modified',
    contnotes     => 'contnotes2 modified',
    active        => 1,
    gstreg        => 1,
    listincgst    => 1,
    invoiceincgst => 1,
    gstrate       => '2.0000 ',
    discount      => '2.0000',
    notes         => 'notes2 modified',
    deliverytime  => 2,
};

#FIXME : ModBookseller always returns undef, even if the id isn't given
#or doesn't exist
my $modif1 = C4::Bookseller::ModBookseller();
is( $modif1, undef,
    "ModBookseller returns undef if no params given - Nothing happened" );
$modif1 = C4::Bookseller::ModBookseller($sample_supplier2);
#is( $modif1, 1, "ModBookseller modifies only the supplier2" );
is( scalar( C4::Bookseller::GetBookSeller('') ),
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
    contact       => 'contact3',
    contpos       => 'contpos3',
    contphone     => 'contphone3',
    contfax       => 'contefax3',
    contaltphone  => 'contaltphone3',
    contemail     => 'contemail3',
    contnotes     => 'contnotes3',
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
    contact       => 'contact4',
    contpos       => 'contpos4',
    contphone     => 'contphone4',
    contfax       => 'contefax4',
    contaltphone  => 'contaltphone4',
    contemail     => 'contemail4',
    contnotes     => 'contnotes4',
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
my $sample_basket3 =
  C4::Acquisition::NewBasket( $id_supplier3, 'authorisedby3', 'basketname3',
    'basketnote3' );
my $sample_basket4 =
  C4::Acquisition::NewBasket( $id_supplier4, 'authorisedby4', 'basketname4',
    'basketnote4' );

#Modify the basket to add a close date
my $basket1info = {
    basketno     => $sample_basket1,
    closedate    => $today,
    booksellerid => $id_supplier1
};

my $basket2info = {
    basketno     => $sample_basket2,
    closedate    => $daysago5,
    booksellerid => $id_supplier2
};

my $dt_today2 = dt_from_string;
my $dur10 = DateTime::Duration->new( days => -10 );
$dt_today2->add_duration($dur10);
my $daysago10 = output_pref( $dt_today2, 'iso', '24hr', 1 );
my $basket3info = {
    basketno  => $sample_basket3,
    closedate => $daysago10,
};

my $basket4info = {
    basketno  => $sample_basket4,
    closedate => $today,
};
ModBasket($basket1info);
ModBasket($basket2info);
ModBasket($basket3info);
ModBasket($basket4info);

#Add 1 subscription
my $id_subscription3 = C4::Serials::NewSubscription(
    undef,      "",            $id_supplier3, undef,
    $id_budget, $biblionumber, '01-01-2013',  undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         undef,
    undef,      undef,         undef,         1,
    "notes",    undef,         undef,         undef,
    undef,      undef,         undef,         0,
    "intnotes", 0,             undef,         undef,
    0,          undef,         '31-12-2013',
);

#Add 4 orders
my ( $ordernumber1, $ordernumber2, $ordernumber3, $ordernumber4 );
my ( $basketno1,    $basketno2,    $basketno3,    $basketno4 );
( $basketno1, $ordernumber1 ) = C4::Acquisition::NewOrder(
    {
        basketno         => $sample_basket1,
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
);
( $basketno2, $ordernumber2 ) = C4::Acquisition::NewOrder(
    {
        basketno       => $sample_basket2,
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
);
( $basketno3, $ordernumber3 ) = C4::Acquisition::NewOrder(
    {
        basketno       => $sample_basket3,
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
);
( $basketno4, $ordernumber4 ) = C4::Acquisition::NewOrder(
    {
        basketno         => $sample_basket4,
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
);

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
#FIXME: If only the field delay is given, it doen't consider the deliverytime
#isnt( exists( $suppliers{$id_supplier2} ),
#    1, "Supplier2 has late orders and $daysago5 <= now() - (4 days+2)" );
ok( exists( $suppliers{$id_supplier3} ),
    "Supplier3 has late orders and $daysago10  <= now() - (4 days+3)" );
isnt( exists( $suppliers{$id_supplier4} ), 1, "Supplier4 hasnt late orders" );

#Case 3: With $delay = -1
#FIXME: GetBooksellersWithLateOrders doesn't test if the delay is a positive value
#is( C4::Bookseller::GetBooksellersWithLateOrders( -1, undef, undef ),
#    undef, "-1 is a wrong value for a delay" );

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
my $daysago4 = output_pref( $dt_today3, 'iso', '24hr', 1 );
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago4, undef );

#FIXME: if the deliverytime is undef, it doesn't consider the supplier
#ok( exists( $suppliers{$id_supplier1} ),
#    "Supplier1 has late orders and $today >= $daysago4 -deliverytime undef" );
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
#FIXME: if only the estimateddeliverydatefrom is given, it doesn't consider the parameters,
#but it replaces it today's date
#isnt( exists( $suppliers{$id_supplier1} ),
#    1,
#    "Supplier1 has late orders but $today >= $daysago5 - deliverytime undef" );
#isnt( exists( $suppliers{$id_supplier2} ),
#    1, "Supplier2 has late orders but  $daysago5 + 2 days  > $daysago5 " );
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
#FIXME: GetBookSellersWithLateOrders replace estimateddeliverydateto by
#today's date when no estimateddeliverydatefrom is give
#isnt(
#    exists( $suppliers{$id_supplier2} ),
#    1,
#"Supplier2 has late orders but $daysago5 + 2 days > $daysago5  and $daysago5 > now() - 2+5 days"
#);
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
    basketno  => $sample_basket1,
    closedate => $daysago10,
};
ModBasket($basket1info);
%suppliers = C4::Bookseller::GetBooksellersWithLateOrders( undef, $daysago10,
    $daysago10 );
#FIXME :GetBookSellers doesn't take care if the closedate is ==$estimateddeliverydateto
# ok( exists( $suppliers{$id_supplier1} ),
#    "Supplier1 has late orders and $daysago10==$daysago10==$daysago10 " )
#  ;
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
#FIXME :GetBookSellers doesn't take care if the closedate is ==$estimateddeliverydateto
#ok( exists( $suppliers{$id_supplier1} ),
#    "Supplier1 has late orders and $daysago10==$daysago10 " );

#Case 13: closedate == $estimateddeliverydateto =today-10
%suppliers =
  C4::Bookseller::GetBooksellersWithLateOrders( undef, undef, $daysago10 );
ok( exists( $suppliers{$id_supplier1} ),
    "Supplier1 has late orders and $daysago10==$daysago10 " )
  ;

#End transaction
$dbh->rollback;

#field_filter filters the useless fields or foreign keys
#NOTE: all the fields of aqbookseller arent considered
#returns a cleaned structure
sub field_filter {
    my ($struct) = @_;

    for my $field (
        'bookselleremail', 'booksellerfax',
        'booksellerurl',   'othersupplier',
        'currency',        'invoiceprice',
        'listprice'
      )
    {

        if ( grep { /^$field$/ } keys %$struct ) {
            delete $struct->{$field};
        }
    }
    return $struct;
}
