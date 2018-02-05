#!/usr/bin/perl

use Modern::Perl;

use C4::Biblio qw( AddBiblio );

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use Koha::Database;

use Test::More tests => 24;

BEGIN {
    use_ok('C4::Acquisition');
}

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q{DELETE FROM aqinvoices});

my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
)->store;
my $booksellerid = $bookseller->id;

my $booksellerinfo = Koha::Acquisition::Booksellers->find( $booksellerid );
my $basketno = NewBasket($booksellerid, 1);
my $basket   = GetBasket($basketno);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test",
        budget_name => "budget_name_test",
    }
);
my $budget = C4::Budgets::GetBudget( $budgetid );

my $bibrec1 = MARC::Record->new();
$bibrec1->append_fields(
    MARC::Field->new('020', '', '', 'a' => '1234567890'),
    MARC::Field->new('100', '', '', 'a' => 'Shakespeare,  Billy'),
    MARC::Field->new('245', '', '', 'a' => 'Bug 8854'),
    MARC::Field->new('260', '', '', 'b' => 'Scholastic Publishing', c => 'c2012'),
);
my ($biblionumber1, $biblioitemnumber1) = AddBiblio($bibrec1, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');
my ($biblionumber3, $biblioitemnumber3) = AddBiblio(MARC::Record->new, '');

my $order1 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 2,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber1 = $order1->ordernumber;

my $order2 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 1,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber2 = $order2->ordernumber;

my $order3 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 1,
        biblionumber => $biblionumber3,
        budget_id => $budget->{budget_id},
        ecost => 42,
        rrp => 42,
    }
)->store;
my $ordernumber3 = $order3->ordernumber;

my $invoiceid1 = AddInvoice(invoicenumber => 'invoice1', booksellerid => $booksellerid, unknown => "unknown");
my $invoiceid2 = AddInvoice(invoicenumber => 'invoice2', booksellerid => $booksellerid, unknown => "unknown",
                            shipmentdate => '2012-12-24',
                           );

my $invoice1 = GetInvoice( $invoiceid1 );
my $invoice2 = GetInvoice( $invoiceid2 );

my ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber1,
        order            => $order1->unblessed,
        quantityreceived => 2,
        invoice          => $invoice1,
    }
);

( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order2->unblessed,
        quantityreceived => 1,
        invoice          => $invoice2,
        rrp              => 42
    }
);

( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber3,
        order            => $order3->unblessed,
        quantityreceived => 1,
        invoice          => $invoice2,
    }
);

$invoice1 = GetInvoiceDetails($invoiceid1);
$invoice2 = GetInvoiceDetails($invoiceid2);

is(scalar @{$invoice1->{'orders'}}, 1, 'Invoice1 has only one order');
is(scalar @{$invoice2->{'orders'}}, 2, 'Invoice2 has only two orders');

my $orders = $invoice1->{orders};
ok( exists( @$orders[0]->{basketgroupid} ), "GetInvoiceDetails: The basketgroupid key exists" );
ok( exists( @$orders[0]->{basketgroupname} ), "GetInvoiceDetails: The basketgroupname key exists" );

my @invoices = GetInvoices();
cmp_ok(scalar @invoices, '>=', 2, 'GetInvoices returns at least two invoices');

@invoices = GetInvoices(invoicenumber => 'invoice2');
cmp_ok(scalar @invoices, '>=', 1, 'GetInvoices returns at least one invoice when a specific invoice is requested');

@invoices = GetInvoices(shipmentdateto => '2012-12-24', shipmentdatefrom => '2012-12-24');
is($invoices[0]->{invoicenumber}, 'invoice2', 'GetInvoices() to search by shipmentdate works (bug 8854)');
@invoices = GetInvoices(title => 'Bug');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by title works (bug 8854)');
@invoices = GetInvoices(author => 'Billy');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by author works (bug 8854)');
@invoices = GetInvoices(publisher => 'Scholastic');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by publisher works (bug 8854)');
@invoices = GetInvoices(publicationyear => '2012');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by publication/copyright year works (bug 8854)');
@invoices = GetInvoices(isbneanissn => '1234567890');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by ISBN works (bug 8854)');
@invoices = GetInvoices(isbneanissn => '123456789');
is($invoices[0]->{invoicenumber}, 'invoice1', 'GetInvoices() to search by partial ISBN works (bug 8854)');

my $invoicesummary1 = GetInvoice($invoiceid1);
is($invoicesummary1->{'invoicenumber'}, 'invoice1', 'GetInvoice retrieves correct invoice');
is($invoicesummary1->{'invoicenumber'}, $invoice1->{'invoicenumber'}, 'GetInvoice and GetInvoiceDetails retrieve same information');

ModInvoice(invoiceid => $invoiceid1, invoicenumber => 'invoice11');
$invoice1 = GetInvoiceDetails($invoiceid1);
is($invoice1->{'invoicenumber'}, 'invoice11', 'ModInvoice changed invoice number');

is($invoice1->{'closedate'}, undef, 'Invoice is not closed before CloseInvoice call');
CloseInvoice($invoiceid1);
$invoice1 = GetInvoiceDetails($invoiceid1);
isnt($invoice1->{'closedate'}, undef, 'Invoice is closed after CloseInvoice call');
ReopenInvoice($invoiceid1);
$invoice1 = GetInvoiceDetails($invoiceid1);
is($invoice1->{'closedate'}, undef, 'Invoice is open after ReopenInvoice call');


MergeInvoices($invoiceid1, [ $invoiceid2 ]);

my $mergedinvoice = GetInvoiceDetails($invoiceid1);
is(scalar @{$mergedinvoice->{'orders'}}, 3, 'Merged invoice has three orders');

my $invoiceid3 = AddInvoice(invoicenumber => 'invoice3', booksellerid => $booksellerid, unknown => "unknown");
my $invoicecount = GetInvoices();
DelInvoice($invoiceid3);
@invoices = GetInvoices();
is(scalar @invoices, $invoicecount - 1, 'DelInvoice deletes invoice');
is(GetInvoice($invoiceid3), undef, 'DelInvoice deleted correct invoice');

my @invoices_linked_to_subscriptions = map{
    $_->{is_linked_to_subscriptions}
    ? $_
    : ()
} @invoices;
is_deeply( \@invoices_linked_to_subscriptions, [], "GetInvoices return linked_to_subscriptions: there is no invoices linked to subscriptions yet" );

END {
    $dbh and $schema->storage->txn_rollback();
}
