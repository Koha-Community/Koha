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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

 spent.pl

=head1 DESCRIPTION

this script is designed to show the spent amount in budgets

=cut

use C4::Context;
use C4::Auth;
use C4::Output;
use Modern::Perl;
use CGI qw ( -utf8 );
use Koha::Acquisition::Invoice::Adjustments;

my $dbh      = C4::Context->dbh;
my $input    = new CGI;
my $bookfund = $input->param('fund');
my $fund_code = $input->param('fund_code');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/spent.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my $query = <<EOQ;
SELECT
    aqorders.biblionumber, aqorders.basketno, aqorders.ordernumber,
    quantity-quantityreceived AS tleft,
    ecost, budgetdate, entrydate,
    aqbasket.booksellerid,
    itype,
    title,
    aqorders.invoiceid,
    aqinvoices.invoicenumber,
    quantityreceived,
    unitprice,
    datereceived
FROM (aqorders, aqbasket)
LEFT JOIN biblio ON
    biblio.biblionumber=aqorders.biblionumber
LEFT JOIN aqorders_items ON
    aqorders.ordernumber = aqorders_items.ordernumber
LEFT JOIN items ON
    aqorders_items.itemnumber = items.itemnumber
LEFT JOIN aqinvoices ON
    aqorders.invoiceid = aqinvoices.invoiceid
WHERE
    aqorders.basketno=aqbasket.basketno AND
    budget_id=? AND
    (datecancellationprinted IS NULL OR
        datecancellationprinted='0000-00-00') AND
    datereceived IS NOT NULL
    GROUP BY aqorders.ordernumber
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
    if ( $recv > 0 ) {
        my $rowtotal = $recv * $data->{'unitprice'};
        $data->{'rowtotal'}  = sprintf( "%.2f", $rowtotal );
        $data->{'unitprice'} = sprintf( "%.2f", $data->{'unitprice'} );
        $subtotal += $rowtotal;
        push @spent, $data;
    }

}

my $total = $subtotal;
$query = qq{
    SELECT invoicenumber, shipmentcost
    FROM aqinvoices
    WHERE shipmentcost_budgetid = ?
};
$sth = $dbh->prepare($query);
$sth->execute($bookfund);
my @shipmentcosts;
while (my $data = $sth->fetchrow_hashref) {
    push @shipmentcosts, {
        shipmentcost => sprintf("%.2f", $data->{shipmentcost}),
        invoicenumber => $data->{invoicenumber}
    };
    $total += $data->{shipmentcost};
}
$sth->finish;

my $adjustments = Koha::Acquisition::Invoice::Adjustments->search({budget_id => $bookfund, closedate => { '!=' => undef } }, { join => 'invoiceid' } );
while ( my $adj = $adjustments->next ){
    $total += $adj->adjustment;
}

$total = sprintf( "%.2f", $total );

$template->param(
    fund => $bookfund,
    spent => \@spent,
    subtotal => $subtotal,
    shipmentcosts => \@shipmentcosts,
    adjustments => $adjustments,
    total => $total,
    fund_code => $fund_code
);

output_html_with_http_headers $input, $cookie, $template->output;
