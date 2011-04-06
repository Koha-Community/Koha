#!/usr/bin/perl


#script to show display basket of orders


# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
#
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

parcels.pl

=head1 DESCRIPTION

This script shows all orders/parcels receipt or pending for a given supplier.
It allows to write an order/parcels as 'received' when he arrives.

=head1 CGI PARAMETERS

=over 4

=item supplierid

To know the supplier this script has to show orders.

=item orderby

sort list of order by 'orderby'.
Orderby can be equals to
    * datereceived desc (default value)
    * aqorders.booksellerinvoicenumber
    * datereceived
    * aqorders.booksellerinvoicenumber desc

=item filter

=item datefrom

To filter on date

=item dateto

To filter on date

=item resultsperpage

To know how many results have to be display / page.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;

use C4::Dates qw/format_date/;
use C4::Acquisition;
use C4::Bookseller qw/ GetBookSellerFromId /;

my $input          = CGI->new;
my $supplierid     = $input->param('supplierid');
my $order          = $input->param('orderby') || 'datereceived desc';
my $startfrom      = $input->param('startfrom');
my $code           = $input->param('filter');
my $datefrom       = $input->param('datefrom');
my $dateto         = $input->param('dateto');
my $resultsperpage = $input->param('resultsperpage');
$resultsperpage ||= 20;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'acqui/parcels.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_receive' },
        debug           => 1,
    }
);

my $bookseller = GetBookSellerFromId($supplierid);
my @parcels = GetParcels( $supplierid, $order, $code, $datefrom, $dateto );
my $count_parcels = @parcels;

# multi page display gestion
$startfrom ||= 0;
if ( $count_parcels > $resultsperpage ) {
    set_page_navigation( $count_parcels, $startfrom, $resultsperpage );
}
my $loopres = [];

my $next_page_start = $startfrom + $resultsperpage;
my $last_row = ( $next_page_start < $count_parcels  ) ? $next_page_start - 1 : $count_parcels - 1;
for my $i ( $startfrom .. $last_row) {
    my $p = $parcels[$i];

    push @{$loopres},
      { number           => $i + 1,
        code             => $p->{booksellerinvoicenumber},
        nullcode         => $p->{booksellerinvoicenumber} eq 'NULL',
        emptycode        => $p->{booksellerinvoicenumber} eq q{},
        raw_datereceived => $p->{datereceived},
        datereceived     => format_date( $p->{datereceived} ),
        bibcount         => $p->{biblio},
        reccount         => $p->{itemsreceived},
        itemcount        => $p->{itemsexpected},
      };
}
if ($count_parcels) {
    $template->param( searchresults => $loopres, count => $count_parcels );
}
$template->param(
    orderby                  => $order,
    filter                   => $code,
    datefrom                 => $datefrom,
    dateto                   => $dateto,
    resultsperpage           => $resultsperpage,
    name                     => $bookseller->{'name'},
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    datereceived_today       => C4::Dates->new()->output(),
    supplierid               => $supplierid,
    GST                      => C4::Context->preference('gist'),
);

output_html_with_http_headers $input, $cookie, $template->output;

sub set_page_navigation {
    my ( $total_rows, $startfrom, $resultsperpage ) = @_;
    my $displaynext = 0;
    my $displayprev = $startfrom;
    my $next_row    = $startfrom + $resultsperpage;
    my $prev_row    = $startfrom - $resultsperpage;

    if ( $total_rows - $next_row > 0 ) {
        $displaynext = 1;
    }

    # set up index numbers for paging
    my $numbers = [];
    if ( $total_rows > $resultsperpage ) {
        my $pages = $total_rows / $resultsperpage;
        if ( $total_rows % $resultsperpage ) {
            ++$pages;
        }

        # set up page indexes for at max 15 pages
        my $max_idx = ( $pages < 15 ) ? $pages : 15;
        my $current_page = ( $startfrom / $resultsperpage ) - 1;
        for my $idx ( 1 .. $max_idx ) {
            push @{$numbers},
              { number    => $idx,
                startfrom => ( $idx - 1 ) * $resultsperpage,
                highlight => ( $idx == $current_page ),
              };
        }
    }

    $template->param(
        numbers     => $numbers,
        displaynext => $displaynext,
        displayprev => $displayprev,
        nextstartfrom => ( ( $next_row < $total_rows ) ? $next_row : $total_rows ),
        prevstartfrom => ( ( $prev_row > 0 ) ? $prev_row : 0 )
    );
    return;
}
