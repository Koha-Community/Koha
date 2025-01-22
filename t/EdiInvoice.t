#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::NoWarnings;
use Test::More tests => 27;
use Koha::EDI;

BEGIN { use_ok('Koha::Edifact') }

my $invoice_file = "$Bin/edi_testfiles/BLSINV337023.CEI";

my $invoice = Koha::Edifact->new( { filename => $invoice_file, } );

isa_ok( $invoice, 'Koha::Edifact' );
my $x                 = $invoice->interchange_header('sender');
my $control_reference = '337023';
is( $x, '5013546025078', "sender returned" );

$x = $invoice->interchange_header('recipient');
is( $x, '5013546121974', "recipient returned" );
$x = $invoice->interchange_header('datetime');
is( $x->[0], '140729', "datetime returned" );
$x = $invoice->interchange_header('interchange_control_reference');
is( $x, $control_reference, "interchange_control_reference returned" );

$x = $invoice->interchange_header('application_reference');
is( $x, 'INVOIC', "application_reference returned" );
$x = $invoice->interchange_trailer('interchange_control_count');
is( $x, 6, "interchange_control_count returned" );

my $messages = $invoice->message_array();

# check inv number from BGM

my $msg_count = @{$messages};
is( $msg_count, 6, 'correct message count returned' );

is( $messages->[0]->message_type, 'INVOIC', 'Message shows correct type' );

my $expected_date = '20140729';
is(
    $messages->[0]->message_date,
    $expected_date, 'Message date correctly returned'
);
is(
    $messages->[0]->tax_point_date,
    $expected_date, 'Tax point date correctly returned'
);

my $expected_invoicenumber = '01975490';

my $invoicenumber = $messages->[1]->docmsg_number();

is( $messages->[0]->buyer_ean,    '5013546121974', 'Buyer ean correct' );
is( $messages->[0]->supplier_ean, '5013546025078', 'Supplier ean correct' );

is(
    $invoicenumber, $expected_invoicenumber,
    'correct invoicenumber extracted'
);

my $lines = $messages->[1]->lineitems();

my $num_lines = @{$lines};

is( $num_lines, 8, "Correct number of lineitems returned" );

# sample invoice was from an early version where order was formatted basketno/ordernumber
my $expected_ordernumber = '2818/74593';

my $ordernumber = $lines->[7]->ordernumber;

is( $ordernumber, $expected_ordernumber, 'correct ordernumber returned' );

my $lineprice = $lines->[7]->price_net;

is( $lineprice, 4.55, 'correct net line price returned' );

$lineprice = $lines->[7]->price_gross;

is( $lineprice, 7.99, 'correct gross line price returned' );

my $tax = $lines->[7]->tax;

is( $tax, 0, 'correct tax amount returned' );

my $tax_rate = $lines->[7]->tax_rate;

is( $tax_rate->{rate}, 0.0, 'correct tax rate returned' );

my $tax_on_charge = $lines->[7]->amt_taxoncharge;

is( $tax_on_charge, 0, 'correct tax on charge value returned' );

my $qty_invoiced = $lines->[7]->quantity_invoiced;

is( $qty_invoiced, 1, 'quantity_invoiced returns correct value' );

my ( $lt, $excl ) = Koha::EDI::_get_invoiced_price( $lines->[7], 1 );
is( $lt,   4.55, 'invoiced price calculated' );
is( $excl, 4.55, 'Price excluding tax returned correctly' );

( $lt, $excl ) = Koha::EDI::_get_invoiced_price( $lines->[7], 2 );
is( $lt, 4.55 / 2, 'invoiced pricei calculated for copies > 1' );
