#!/usr/bin/perl

# Copyright 2008 - 2009 BibLibre SARL
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

ordered.pl

=head1 DESCRIPTION

this script is to show orders ordered but not yet received

=cut

use C4::Context;
use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;

my $dbh     = C4::Context->dbh;
my $input   = new CGI;
my $fund_id = $input->param('fund');
my $fund_code = $input->param('fund_code');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/ordered.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my $query = <<EOQ;
SELECT
    aqorders.basketno, aqorders.ordernumber,
    quantity-quantityreceived AS tleft,
    ecost, budgetdate, entrydate,
    aqbasket.booksellerid,
    itype,
    title
FROM (aqorders, aqbasket)
LEFT JOIN biblio ON
    biblio.biblionumber=aqorders.biblionumber
LEFT JOIN aqorders_items ON
    aqorders.ordernumber=aqorders_items.ordernumber
LEFT JOIN items ON
    items.itemnumber=aqorders_items.itemnumber
WHERE
    aqorders.basketno=aqbasket.basketno AND
    budget_id=? AND
    (datecancellationprinted IS NULL OR
        datecancellationprinted='0000-00-00') AND
    (quantity > quantityreceived OR quantityreceived IS NULL)
    GROUP BY aqorders.ordernumber
EOQ

my $sth = $dbh->prepare($query);

$sth->execute($fund_id);
if ( $sth->err ) {
    die "Error occurred fetching records: " . $sth->errstr;
}
my @ordered;

my $total = 0;
while ( my $data = $sth->fetchrow_hashref ) {
    my $left = $data->{'tleft'};
    if ( !$left || $left eq '' ) {
        $left = $data->{'quantity'};
    }
    if ( $left && $left > 0 ) {
        my $subtotal = $left * $data->{'ecost'};
        $data->{subtotal} = sprintf( "%.2f", $subtotal );
        $data->{'left'} = $left;
        push @ordered, $data;
        $total += $subtotal;
    }
}
$total = sprintf( "%.2f", $total );

$template->{VARS}->{'fund'}    = $fund_id;
$template->{VARS}->{'ordered'} = \@ordered;
$template->{VARS}->{'total'}   = $total;
$template->{VARS}->{'fund_code'} = $fund_code;

$sth->finish;

output_html_with_http_headers $input, $cookie, $template->output;
