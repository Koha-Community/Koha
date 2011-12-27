#!/usr/bin/perl

# script to show a breakdown of committed and spent budgets

# Copyright 2002-2009 Katipo Communications Limited
# Copyright 2010 Catalyst IT Limited
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

 spent.pl

=head1 DESCRIPTION

this script is designed to show the spent amount in budges

=cut


use C4::Context;
use C4::Auth;
use C4::Output;
use strict;
use CGI;

my $dbh      = C4::Context->dbh;
my $input    = new CGI;
my $bookfund = $input->param('fund');
my $start    = $input->param('start');
my $end      = $input->param('end');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/spent.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

my $query = <<EOQ;
SELECT
    aqorders.basketno, aqorders.ordernumber,
    quantity-quantityreceived AS tleft,
    ecost, budgetdate,
    aqbasket.booksellerid,
    itype,
    title,
    aqorders.booksellerinvoicenumber,
    quantityreceived,
    unitprice,
    freight,
    datereceived,
    aqorders.biblionumber
FROM (aqorders, aqbasket)
LEFT JOIN items ON
    items.biblioitemnumber=aqorders.biblioitemnumber
LEFT JOIN biblio ON
    biblio.biblionumber=aqorders.biblionumber
LEFT JOIN aqorders_items ON
    aqorders.ordernumber=aqorders_items.ordernumber
WHERE
    aqorders.basketno=aqbasket.basketno AND
    budget_id=? AND
    (datecancellationprinted IS NULL OR
        datecancellationprinted='0000-00-00')
    GROUP BY aqorders.ordernumber
EOQ
my $sth = $dbh->prepare($query);
$sth->execute( $bookfund);
if ($sth->err) {
    die "An error occurred fetching records: ".$sth->errstr;
}
my $total = 0;
my $toggle;
my @spent;
while ( my $data = $sth->fetchrow_hashref ) {
    my $recv = $data->{'quantityreceived'};
    if ( $recv > 0 ) {
        my $subtotal = $recv * ($data->{'unitprice'} + $data->{'freight'});
        $data->{'subtotal'}  =   sprintf ("%.2f",  $subtotal);
	$data->{'freight'}   =   sprintf ("%.2f", $data->{'freight'});
        $data->{'unitprice'} =   sprintf ("%.2f",   $data->{'unitprice'}  );
        $total               += $subtotal;

        if ($toggle) {
            $toggle = 0;
        }
        else {
            $toggle = 1;
        }
        $data->{'toggle'} = $toggle;
        push @spent, $data;
    }

}
$total =   sprintf ("%.2f",  $total);

$template->param(
    spent       => \@spent,
    total       => $total
);
$sth->finish;

$dbh->disconnect;
output_html_with_http_headers $input, $cookie, $template->output;
