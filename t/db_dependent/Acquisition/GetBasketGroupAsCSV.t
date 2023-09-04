#!/usr/bin/perl

use Modern::Perl;

use CGI;

use Test::More tests => 2;

use C4::Acquisition qw( NewBasket NewBasketgroup GetBasketGroupAsCSV );
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::CsvProfiles;
use Koha::Acquisition::Orders;
use Koha::Biblios;

use t::lib::Mocks;
use Try::Tiny;

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

my $basketno = C4::Acquisition::NewBasket($vendor->id, 1);

my $basketgroupid = C4::Acquisition::NewBasketgroup(
    {
        booksellerid  => $vendor->id,
        basketlist    => [ $basketno ],
    }
);

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

my $basketgroup_csv1 = C4::Acquisition::GetBasketGroupAsCSV( $basketgroupid, $query );
is(
    $basketgroup_csv1,
    '"Account number","Basket name","Order number","Author","Title","Publisher","Publication year","Collection title","ISBN","Quantity","RRP tax included","RRP tax excluded","Discount","Estimated cost tax included","Estimated cost tax excluded","Note for vendor","Entry date","Bookseller name","Bookseller physical address","Bookseller postal address","Contract number","Contract name","Basket group delivery place","Basket group billing place","Basket delivery place","Basket billing place"
,"",'
        . $order->ordernumber
        . ',"King, Stephen","Test Record","",,"",,3,0.00,0.00,,0.00,0.00,"",2016-01-02,"my vendor","vendor address","",,"","","","",""
', 'CSV should be generated'
);

Koha::Biblios->find($biblionumber)->delete;
my $basketgroup_csv2 = C4::Acquisition::GetBasketGroupAsCSV( $basketgroupid, $query );
is(
    $basketgroup_csv2,
    '"Account number","Basket name","Order number","Author","Title","Publisher","Publication year","Collection title","ISBN","Quantity","RRP tax included","RRP tax excluded","Discount","Estimated cost tax included","Estimated cost tax excluded","Note for vendor","Entry date","Bookseller name","Bookseller physical address","Bookseller postal address","Contract number","Contract name","Basket group delivery place","Basket group billing place","Basket delivery place","Basket billing place"
,"",'
        . $order->ordernumber
        . ',"","","",,"",,3,0.00,0.00,,0.00,0.00,"",2016-01-02,"my vendor","vendor address","",,"","","","",""
', 'CSV should not fail if biblio does not exist'
);

$schema->storage->txn_rollback();
