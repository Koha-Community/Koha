#!/usr/bin/perl

# Script to move an order from a bookseller to another

# Copyright 2011 BibLibre SARL
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Members;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/transferorder.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

my $dbh = C4::Context->dbh;

my $bookselleridfrom    = $input->param('bookselleridfrom');
my $ordernumber     = $input->param('ordernumber');
my $bookselleridto  = $input->param('bookselleridto');
my $basketno        = $input->param('basketno');
my $op              = $input->param('op');
my $query           = $input->param('query');

my $order = GetOrder($ordernumber);
my $basketfromname = '';
if($order) {
    my $basket = GetBasket($order->{basketno});
    $basketfromname = $basket->{basketname};
    $bookselleridfrom = $basket->{booksellerid} if $basket;
}

my $booksellerfrom = Koha::Acquisition::Bookseller->fetch({ id => $bookselleridfrom });
my $booksellerfromname;
if($booksellerfrom){
    $booksellerfromname = $booksellerfrom->{name};
}
my $booksellerto = Koha::Acquisition::Bookseller->fetch({ id => $bookselleridto });
my $booksellertoname;
if($booksellerto){
    $booksellertoname = $booksellerto->{name};
}


if( $basketno && $ordernumber) {
    # Transfer order and exit
    my $order = GetOrder( $ordernumber );
    my $basket = GetBasket($order->{basketno});
    my $booksellerfrom = Koha::Acquisition::Bookseller->fetch({ id => $basket->{booksellerid} });
    my $bookselleridfrom = $booksellerfrom->{id};

    TransferOrder($ordernumber, $basketno);

    $template->param(transferred => 1)
} elsif ( $bookselleridto && $ordernumber) {
    # Show open baskets for this bookseller
    my $order = GetOrder( $ordernumber );
    my $basketfrom = GetBasket( $order->{basketno} );
    my $booksellerfrom = Koha::Acquisition::Bookseller->fetch({ id => $basketfrom->{booksellerid} });
    $booksellerfromname = $booksellerfrom->{name};
    my $baskets = GetBasketsByBookseller( $bookselleridto );
    my $basketscount = scalar @$baskets;
    my @basketsloop = ();
    for( my $i = 0 ; $i < $basketscount ; $i++ ){
        my %line;
        %line = %{ $baskets->[$i] };
        my $createdby = GetMember(borrowernumber => $line{authorisedby});
        $line{createdby} = "$createdby->{surname}, $createdby->{firstname}";
        push @basketsloop, \%line unless $line{closedate};
    }
    $template->param(
        show_baskets => 1,
        basketsloop => \@basketsloop,
        basketfromname => $basketfrom->{basketname},
    );
} elsif ( $bookselleridfrom && !defined $ordernumber) {
    # Show pending orders
    my $pendingorders = SearchOrders({
        booksellerid => $bookselleridfrom,
        pending      => 1,
    });
    my $orderscount = scalar @$pendingorders;
    my @ordersloop = ();
    for( my $i = 0 ; $i < $orderscount ; $i++ ){
        my %line;
        %line = %{ $pendingorders->[$i] };
        push @ordersloop, \%line;
    }
    $template->param(
        ordersloop  => \@ordersloop,
    );
} else {
    # Search for booksellers to transfer from/to
    $op = '' unless $op;
    if( $op eq "do_search" ) {
        my @booksellers = Koha::Acquisition::Bookseller->search({ name => $query });
        $template->param(
            query => $query,
            do_search => 1,
            booksellersloop => \@booksellers,
        );
    }
}

$template->param(
    bookselleridfrom    => $bookselleridfrom,
    booksellerfromname  => $booksellerfromname,
    bookselleridto      => $bookselleridto,
    booksellertoname    => $booksellertoname,
    ordernumber         => $ordernumber,
    basketno            => $basketno,
    basketfromname      => $basketfromname,
);

output_html_with_http_headers $input, $cookie, $template->output;

