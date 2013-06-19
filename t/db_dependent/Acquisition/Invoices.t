#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use C4::Bookseller qw( GetBookSellerFromId );
use C4::Biblio qw( AddBiblio );

use Test::More tests => 14;

BEGIN {
    use_ok('C4::Acquisition');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $booksellerinfo = GetBookSellerFromId( $booksellerid );
my $basketno = NewBasket($booksellerid, 1);
my $basket   = GetBasket($basketno);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
    }
);
my $budget = C4::Budgets::GetBudget( $budgetid );

my ($ordernumber1, $ordernumber2, $ordernumber3);
my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');
my ($biblionumber3, $biblioitemnumber3) = AddBiblio(MARC::Record->new, '');
( undef, $ordernumber1 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 2,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
);

( undef, $ordernumber2 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 1,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
);

( undef, $ordernumber3 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 1,
        biblionumber => $biblionumber3,
        budget_id => $budget->{budget_id},
        ecost => 42,
        rrp => 42,
    }
);

my $invoiceid1 = AddInvoice(invoicenumber => 'invoice1', booksellerid => $booksellerid, unknown => "unknown");
my $invoiceid2 = AddInvoice(invoicenumber => 'invoice2', booksellerid => $booksellerid, unknown => "unknown");

my ($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber1,
    $ordernumber1,
    2,
    undef,
    12,
    12,
    $invoiceid1,
    42
    );

($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber2,
    $ordernumber2,
    1,
    undef,
    5,
    5,
    $invoiceid2,
    42
    );

($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber3,
    $ordernumber3,
    1,
    undef,
    12,
    12,
    $invoiceid2,
    42
    );


my $invoice1 = GetInvoiceDetails($invoiceid1);
my $invoice2 = GetInvoiceDetails($invoiceid2);

is(scalar @{$invoice1->{'orders'}}, 1, 'Invoice1 has only one order');
is(scalar @{$invoice2->{'orders'}}, 2, 'Invoice2 has only two orders');

my @invoices = GetInvoices();
cmp_ok(scalar @invoices, '>=', 2, 'GetInvoices returns at least two invoices');

@invoices = GetInvoices(invoicenumber => 'invoice2');
cmp_ok(scalar @invoices, '>=', 1, 'GetInvoices returns at least one invoice when a specific invoice is requested');

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

END {
    $dbh and $dbh->rollback;
}
