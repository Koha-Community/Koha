#!/usr/bin/perl

# Copyright 2012 BibLibre
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Acquisition;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Serials;

use Koha::Acquisition::Bookseller;

my $query        = new CGI;
my $title        = $query->param('title_filter');
my $ISSN         = $query->param('ISSN_filter');
my $EAN          = $query->param('EAN_filter');
my $publisher    = $query->param('publisher_filter');
my $supplier     = $query->param('supplier_filter');
my $branch       = $query->param('branch_filter');
my $routing      = $query->param('routing') || C4::Context->preference("RoutingSerials");
my $searched     = $query->param('searched');
my $biblionumber = $query->param('biblionumber');

my $basketno     = $query->param('basketno');
my $booksellerid = $query->param('booksellerid');

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {   template_name   => "acqui/newordersubscription.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

my $basket = GetBasket($basketno);
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });

my @subscriptions;
if ($searched) {
    @subscriptions = SearchSubscriptions({
        title => $title,
        issn => $ISSN,
        ean => $EAN,
        publisher => $publisher,
        bookseller => $supplier,
        branch => $branch
    });
}

foreach my $sub (@subscriptions) {
    $sub->{alreadyOnOrder} = subscriptionCurrentlyOnOrder $sub->{subscriptionid};

    # to toggle between create or edit routing list options
    if ($routing) {
        $sub->{routingedit} = check_routing( $sub->{subscriptionid} );
    }
}

$template->param(
    subs_loop        => \@subscriptions,
    title_filter     => $title,
    ISSN_filter      => $ISSN,
    EAN_filter       => $EAN,
    publisher_filter => $publisher,
    supplier_filter  => $supplier,
    branch_filter    => $branch,
    done_searched    => $searched,
    routing          => $routing,
    booksellerid     => $booksellerid,
    basketno         => $basket->{basketno},
    basketname       => $basket->{basketname},
    booksellername   => $bookseller->{name},
);
output_html_with_http_headers $query, $cookie, $template->output;
