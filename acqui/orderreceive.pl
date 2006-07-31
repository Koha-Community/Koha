#!/usr/bin/perl

# $Id$

#script to recieve orders
#written by chris@katipo.co.nz 24/2/2000

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

orderreceive.pl

=head1 DESCRIPTION
This script shows all order already receive and all pendings orders.
It permit to write a new order as 'received'.

=head1 CGI PARAMETERS

=over 4

=item supplierid
to know on what supplier this script has to display receive order.

=item recieve

=item invoice
the number of this invoice.

=item freight

=item biblio
The biblionumber of this order.

=item catview

=item gst

=back

=cut

use strict;
use CGI;
use C4::Context;
use C4::Acquisition;
use C4::Koha;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Date;
use C4::Bookseller;
use C4::Members;

my $input      = new CGI;
my $supplierid = $input->param('supplierid');
my $dbh        = C4::Context->dbh;

my $search  = $input->param('recieve');
my $invoice = $input->param('invoice');
my $freight = $input->param('freight');
my $biblio  = $input->param('biblio');
my $catview = $input->param('catview');
my $gst     = $input->param('gst');
my @results = SearchOrder( $search, $supplierid, $biblio, $catview );
my $count = scalar @results;

# warn "C:$count for ordersearch($search,$supplierid,$biblio,$catview);";
my @booksellers = GetBookSeller( $results[0]->{'booksellerid'} );

my $date = $results[0]->{'entrydate'};

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
{
        template_name   => "acqui/orderreceive.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
}
);
$template->param($count);
my ($flags, $homebranch) = GetFlagsAndBranchFromBorrower($loggedinuser);

if ( $count == 1 ) {
    my $sth;

    my $branches = GetBranches;
    my @branchloop;
    foreach my $thisbranch ( sort keys %$branches ) {
        my %row = (
            value      => $thisbranch,
            branchname => $branches->{$thisbranch}->{'branchname'},
        );
        push @branchloop, \%row;
}

    my $auto_barcode = C4::Context->boolean_preference("autoBarcode") || 0;

# See whether barcodes should be automatically allocated.
# Defaults to 0, meaning "no".
    my $barcode;
    if ( $auto_barcode eq '1' ) {
        $sth = $dbh->prepare("Select max(barcode) from items");
        $sth->execute;
        my $data = $sth->fetchrow_hashref;
        $barcode = $results[0]->{'barcode'} + 1;
        $sth->finish;
}

    if ( $results[0]->{'quantityreceived'} == 0 ) {
        $results[0]->{'quantityreceived'} = '';
}
    if ( $results[0]->{'unitprice'} == 0 ) {
        $results[0]->{'unitprice'} = '';
}
    $template->param(
        branchloop       => \@branchloop,
        count            => 1,
        biblionumber     => $results[0]->{'biblionumber'},
        ordernumber      => $results[0]->{'ordernumber'},
        biblioitemnumber => $results[0]->{'biblioitemnumber'},
        supplierid       => $results[0]->{'booksellerid'},
        freight          => $freight,
        gst              => $gst,
        catview          => ( $catview ne 'yes' ? 1 : 0 ),
        name             => $booksellers[0]->{'name'},
        date             => format_date($date),
        title            => $results[0]->{'title'},
        author           => $results[0]->{'author'},
        copyrightdate    => format_date( $results[0]->{'copyrightdate'} ),
        itemtype         => $results[0]->{'itemtype'},
        isbn             => $results[0]->{'isbn'},
        seriestitle      => $results[0]->{'seriestitle'},
        barcode          => $barcode,
        bookfund         => $results[0]->{'bookfundid'},
        quantity         => $results[0]->{'quantity'},
        quantityreceived => $results[0]->{'quantityreceived'},
        rrp              => $results[0]->{'rrp'},
        ecost            => $results[0]->{'ecost'},
        unitprice        => $results[0]->{'unitprice'},
        invoice          => $invoice,
        notes            => $results[0]->{'notes'},
    );
}
else {
    my @loop;
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        my %line;
        $line{isbn}             = $results[$i]->{'isbn'};
        $line{basketno}         = $results[$i]->{'basketno'};
        $line{quantity}         = $results[$i]->{'quantity'};
        $line{quantityrecieved} = $results[$i]->{'quantityreceived'};
        $line{ordernumber}      = $results[$i]->{'ordernumber'};
        $line{biblionumber}     = $results[$i]->{'biblionumber'};
        $line{invoice}          = $invoice;
        $line{freight}          = $freight;
        $line{gst}              = $gst;
        $line{title}            = $results[$i]->{'title'};
        $line{author}           = $results[$i]->{'author'};
        $line{supplierid}       = $supplierid;
        push @loop, \%line;
}
    $template->param(
        loop       => \@loop,
        date       => format_date($date),
        name       => $booksellers[0]->{'name'},
        supplierid => $supplierid,
        invoice    => $invoice,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;

