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
use Modern::Perl;
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Acquisition::Invoice::Adjustments;
use C4::Acquisition qw( get_rounded_price );

my $dbh       = C4::Context->dbh;
my $input     = CGI->new;
my $fund_id   = $input->param('fund');
my $fund_code = $input->param('fund_code');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/ordered.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => '*' },
    }
);

# Choose correct ecost field
my ( $unitprice_field, $ecost_field ) = C4::Budgets->FieldsForCalculatingFundValues();

my $query = <<EOQ;
SELECT
    aqorders.biblionumber, aqorders.basketno, aqorders.ordernumber,
    quantity-quantityreceived AS tleft,
    $ecost_field, budgetdate, entrydate,
    aqbasket.booksellerid,
    aqbooksellers.name as vendorname,
    GROUP_CONCAT(DISTINCT itype SEPARATOR '|') AS itypes,
    title
FROM aqorders
JOIN aqbasket USING (basketno)
LEFT JOIN biblio ON
    biblio.biblionumber=aqorders.biblionumber
LEFT JOIN aqorders_items ON
    aqorders.ordernumber=aqorders_items.ordernumber
LEFT JOIN items ON
    items.itemnumber=aqorders_items.itemnumber
LEFT JOIN aqbooksellers ON
    aqbasket.booksellerid = aqbooksellers.id
WHERE
    budget_id=? AND
    datecancellationprinted IS NULL AND
    (quantity > quantityreceived OR quantityreceived IS NULL)
    GROUP BY aqorders.biblionumber, aqorders.basketno, aqorders.ordernumber,
             tleft,
             $ecost_field, budgetdate, entrydate,
             aqbasket.booksellerid,
             aqbooksellers.name,
             title
EOQ

my $sth = $dbh->prepare($query);

$sth->execute($fund_id);
if ( $sth->err ) {
    die "Error occurred fetching records: " . $sth->errstr;
}
my @ordered;

my $total = 0;
while ( my $data = $sth->fetchrow_hashref ) {
    $data->{'itemtypes'} = [ split( '\|', $data->{itypes} ) ];
    my $left = $data->{'tleft'};
    if ( !$left || $left eq '' ) {
        $left = $data->{'quantity'};
    }
    if ( $left && $left > 0 ) {
        my $subtotal = $left * get_rounded_price( $data->{$ecost_field} );
        $data->{subtotal} = sprintf( "%.2f", $subtotal );
        $data->{'left'}   = $left;
        push @ordered, $data;
        $total += $subtotal;
    }
}

my $adjustments = Koha::Acquisition::Invoice::Adjustments->search(
    { budget_id => $fund_id, closedate => undef, encumber_open => 1 },
    { prefetch  => 'invoiceid' }
);
while ( my $adj = $adjustments->next ) {
    $total += $adj->adjustment;
}

$total = sprintf( "%.2f", $total );

$template->{VARS}->{'fund'}        = $fund_id;
$template->{VARS}->{'ordered'}     = \@ordered;
$template->{VARS}->{'total'}       = $total;
$template->{VARS}->{'fund_code'}   = $fund_code;
$template->{VARS}->{'adjustments'} = $adjustments;

$sth->finish;

output_html_with_http_headers $input, $cookie, $template->output;
