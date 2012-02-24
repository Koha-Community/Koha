#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
# Copyright 2010 PTFS Europe Ltd
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

supplier.pl

=head1 DESCRIPTION

this script shows the details for a bookseller given on input arg.
It allows to edit & save information about this bookseller.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

To know the bookseller this script has to display details.

=back

=cut

use strict;
use warnings;
use C4::Auth;
use C4::Contract qw/GetContract/;
use C4::Biblio;
use C4::Output;
use CGI;

use C4::Bookseller qw( GetBookSellerFromId DelBookseller );
use C4::Budgets;

my $query    = CGI->new;
my $booksellerid       = $query->param('booksellerid');
my $supplier = {};
if ($booksellerid) {
    $supplier = GetBookSellerFromId($booksellerid);
}
my $op = $query->param('op') || 'display';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'acqui/supplier.tmpl',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

#build array for currencies
if ( $op eq 'display' ) {

    my $contracts = GetContract( { booksellerid => $booksellerid } );

    $template->param(
        booksellerid  => $booksellerid,
        name          => $supplier->{'name'},
        postal        => $supplier->{'postal'},
        address1      => $supplier->{'address1'},
        address2      => $supplier->{'address2'},
        address3      => $supplier->{'address3'},
        address4      => $supplier->{'address4'},
        phone         => $supplier->{'phone'},
        accountnumber => $supplier->{'accountnumber'},
        fax           => $supplier->{'fax'},
        url           => $supplier->{'url'},
        contact       => $supplier->{'contact'},
        contpos       => $supplier->{'contpos'},
        contphone     => $supplier->{'contphone'},
        contaltphone  => $supplier->{'contaltphone'},
        contfax       => $supplier->{'contfax'},
        contemail     => $supplier->{'contemail'},
        contnotes     => $supplier->{'contnotes'},
        notes         => $supplier->{'notes'},
        active        => $supplier->{'active'},
        gstreg        => $supplier->{'gstreg'},
        listincgst    => $supplier->{'listincgst'},
        invoiceincgst => $supplier->{'invoiceincgst'},
        gstrate       => $supplier->{'gstrate'} + 0.0,
        discount      => $supplier->{'discount'},
        deliverytime  => $supplier->{deliverytime},
        invoiceprice  => $supplier->{'invoiceprice'},
        listprice     => $supplier->{'listprice'},
        basketcount   => $supplier->{'basketcount'},
        subscriptioncount   => $supplier->{'subscriptioncount'},
        contracts     => $contracts,
        dateformat    => C4::Context->preference("dateformat"),
    );
} elsif ( $op eq 'delete' ) {
    # no further message needed for the user
    # the DELETE button only appears in the template if basketcount == 0
    if ( $supplier->{'basketcount'} == 0 ) {
        DelBookseller($booksellerid);
    }
    print $query->redirect('/cgi-bin/koha/acqui/acqui-home.pl');
    exit;
} else {
    my @currencies = GetCurrencies();
    my $loop_currency;
    my $active_currency = GetCurrency();
    my $active_listprice = $supplier->{'listprice'};
    my $active_invoiceprice = $supplier->{'invoiceprice'};
    if (!$supplier->{listprice}) {
        $active_listprice =  $active_currency->{currency};
    }
    if (!$supplier->{invoiceprice}) {
        $active_invoiceprice =  $active_currency->{currency};
    }
    for (@currencies) {
        push @{$loop_currency},
            { 
            currency     => $_->{currency},
            listprice    => ( $_->{currency} eq $active_listprice ),
            invoiceprice => ( $_->{currency} eq $active_invoiceprice ),
            };
    }

    # get option values from gist syspref
    my @gst_values = map {
        option => $_
    }, split( '\|', C4::Context->preference("gist") );

    $template->param(
        booksellerid => $booksellerid,
        name         => $supplier->{'name'},
        postal       => $supplier->{'postal'},
        address1     => $supplier->{'address1'},
        address2     => $supplier->{'address2'},
        address3     => $supplier->{'address3'},
        address4     => $supplier->{'address4'},
        phone        => $supplier->{'phone'},
        accountnumber=> $supplier->{'accountnumber'},
        fax          => $supplier->{'fax'},
        url          => $supplier->{'url'},
        contact      => $supplier->{'contact'},
        contpos      => $supplier->{'contpos'},
        contphone    => $supplier->{'contphone'},
        contaltphone => $supplier->{'contaltphone'},
        contfax      => $supplier->{'contfax'},
        contemail    => $supplier->{'contemail'},
        contnotes    => $supplier->{'contnotes'},
        notes        => $supplier->{'notes'},
        # set active ON by default for supplier add (id empty for add)
        active       => $booksellerid ? $supplier->{'active'} : 1,
        gstreg        => $supplier->{'gstreg'},
        listincgst    => $supplier->{'listincgst'},
        invoiceincgst => $supplier->{'invoiceincgst'},
        gstrate       => $supplier->{gstrate} ? $supplier->{'gstrate'}+0.0 : 0,
        gst_values    => \@gst_values,
        discount      => $supplier->{'discount'},
        deliverytime  => $supplier->{deliverytime},
        loop_currency => $loop_currency,
        enter         => 1,
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
