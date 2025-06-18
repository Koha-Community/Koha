#!/usr/bin/perl

# script to show a breakdown of committed and spent budgets

# Copyright 2002-2009 Katipo Communications Limited
# Copyright 2010,2011 Catalyst IT Limited
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

acqui/spent.pl

=head1 DESCRIPTION

this script is designed to show the spent amount in budgets

=cut

use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Modern::Perl;
use CGI             qw ( -utf8 );
use C4::Acquisition qw( get_rounded_price );
use Koha::Acquisition::Invoice::Adjustments;

my $dbh       = C4::Context->dbh;
my $input     = CGI->new;
my $bookfund  = $input->param('fund');
my $fund_code = $input->param('fund_code');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/spent.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => '*' },
    }
);

# Get correct unitprice field
my ($unitprice_field) = C4::Budgets->FieldsForCalculatingFundValues();

my $query = <<EOQ;
SELECT
    aqorders.biblionumber, aqorders.basketno, aqorders.ordernumber,
    quantity-quantityreceived AS tleft,
    budgetdate, entrydate,
    aqbasket.booksellerid,
    GROUP_CONCAT(DISTINCT itype SEPARATOR '|') as itypes,
    title,
    aqorders.invoiceid,
    aqinvoices.invoicenumber,
    quantityreceived,
    $unitprice_field,
    datereceived,
    aqbooksellers.name as vendorname
FROM (aqorders, aqbasket)
LEFT JOIN biblio ON
    biblio.biblionumber=aqorders.biblionumber
LEFT JOIN aqorders_items ON
    aqorders.ordernumber = aqorders_items.ordernumber
LEFT JOIN items ON
    aqorders_items.itemnumber = items.itemnumber
LEFT JOIN aqinvoices ON
    aqorders.invoiceid = aqinvoices.invoiceid
LEFT JOIN aqbooksellers ON
    aqbasket.booksellerid = aqbooksellers.id
WHERE
    aqorders.basketno=aqbasket.basketno AND
    budget_id=? AND
    datecancellationprinted IS NULL AND
    datereceived IS NOT NULL
    GROUP BY aqorders.biblionumber, aqorders.basketno, aqorders.ordernumber,
             tleft,
             budgetdate, entrydate,
             aqbasket.booksellerid,
             title,
             aqorders.invoiceid,
             aqinvoices.invoicenumber,
             quantityreceived,
             $unitprice_field,
             datereceived,
             aqbooksellers.name

EOQ
my $sth = $dbh->prepare($query);
$sth->execute($bookfund);
if ( $sth->err ) {
    die "An error occurred fetching records: " . $sth->errstr;
}
my $subtotal = 0;
my @spent;
while ( my $data = $sth->fetchrow_hashref ) {
    my $recv = $data->{'quantityreceived'};
    $data->{'itemtypes'} = [ split( '\|', $data->{itypes} ) ];
    if ( $recv > 0 ) {
        my $rowtotal = $recv * get_rounded_price( $data->{$unitprice_field} );
        $data->{'rowtotal'}               = sprintf( "%.2f", $rowtotal );
        $data->{'unitprice_tax_included'} = sprintf( "%.2f", $data->{$unitprice_field} );
        $subtotal += $rowtotal;
        push @spent, $data;
    }

}

my $total = $subtotal;
$query = qq{
    SELECT invoiceid, invoicenumber, shipmentcost
    FROM aqinvoices
    WHERE shipmentcost_budgetid = ?
};
$sth = $dbh->prepare($query);
$sth->execute($bookfund);
my @shipmentcosts;
while ( my $data = $sth->fetchrow_hashref ) {
    push @shipmentcosts, {
        shipmentcost  => sprintf( "%.2f", $data->{shipmentcost} ),
        invoiceid     => $data->{invoiceid},
        invoicenumber => $data->{invoicenumber}
    };
    $total += $data->{shipmentcost};
}
$sth->finish;

my $adjustments = Koha::Acquisition::Invoice::Adjustments->search(
    { budget_id => $bookfund, closedate => { '!=' => undef } },
    { prefetch  => 'invoiceid' },
);
while ( my $adj = $adjustments->next ) {
    $total += $adj->adjustment;
}

$total = sprintf( "%.2f", $total );

$template->param(
    fund          => $bookfund,
    spent         => \@spent,
    subtotal      => $subtotal,
    shipmentcosts => \@shipmentcosts,
    adjustments   => $adjustments,
    total         => $total,
    fund_code     => $fund_code
);

output_html_with_http_headers $input, $cookie, $template->output;
