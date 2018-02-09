#!/usr/bin/perl

use Modern::Perl;

use CGI;

use Test::More tests => 3;

use C4::Acquisition;
use C4::Biblio;
use Koha::Database;
use Koha::CsvProfile;

use Koha::Acquisition::Orders;
use t::lib::Mocks;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $query = CGI->new();

my $vendor = Koha::Acquisition::Bookseller->new({
    name => 'my vendor',
    address1 => 'vendor address',
    active => 1,
    deliverytime => 5,
})->store;

my $budget_id = C4::Budgets::AddBudget({
    budget_code => 'my_budget_code',
    budget_name => 'My budget name',
});
my $budget = C4::Budgets::GetBudget( $budget_id );

my $csv_profile = Koha::CsvProfile->new({
    profile => 'my user profile',
    type => 'export_basket',
    csv_separator => ',',
    content => 'autor=biblio.author|title=biblio.title|quantity=aqorders.quantity',
})->store;

my $csv_profile2 = Koha::CsvProfile->new({
    profile => 'my user profile',
    type => 'export_basket',
    csv_separator => ',',
    content => 'biblio.author | title = biblio.title|quantity=aqorders.quantity',
})->store;

my $basketno;
$basketno = NewBasket($vendor->id, 1);

my $biblio = MARC::Record->new();
$biblio->append_fields(
    MARC::Field->new( '100', ' ', ' ', a => 'King, Stephen' ),
    MARC::Field->new( '245', ' ', ' ', a => 'Test Record' ),
);
my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');

my $order = Koha::Acquisition::Order->new({
    basketno => $basketno,
    quantity => 3,
    biblionumber => $biblionumber,
    budget_id => $budget_id,
    entrydate => '2016-01-02',
})->store;

# Use user CSV profile
my $basket_csv1 = C4::Acquisition::GetBasketAsCSV($basketno, $query, $csv_profile->export_format_id);
is($basket_csv1, 'autor,title,quantity
"King, Stephen","Test Record",3
', 'CSV should be generated with user profile');

# Use default template
t::lib::Mocks::mock_preference('delimiter', ',');
my $basket_csv2 = C4::Acquisition::GetBasketAsCSV($basketno, $query);
is($basket_csv2, 'Contract name,Order number,Entry date,ISBN,Author,Title,Publication year,Publisher,Collection title,Note for vendor,Quantity,RRP,Delivery place,Billing place
"",' . $order->ordernumber  . ',2016-01-02,,"King, Stephen","Test Record",,"","","",3,,"",""
', 'CSV should be generated with default template');

my $basket_csv3 = C4::Acquisition::GetBasketAsCSV($basketno, $query, $csv_profile2->export_format_id);
is($basket_csv3, 'biblio.author,title,quantity
"King, Stephen","Test Record",3
', 'CSV should be generated with user profile which does not have all headers defined');

$schema->storage->txn_rollback();
