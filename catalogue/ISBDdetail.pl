#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

ISBDdetail.pl : script to show a biblio in ISBD format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs a biblionumber as parameter 

=head1 FUNCTIONS

=cut

use Modern::Perl;

use HTML::Entities;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output  qw( output_html_with_http_headers );
use CGI         qw ( -utf8 );
use C4::Biblio  qw( GetBiblioData GetISBDView );
use C4::Serials qw( CountSubscriptionFromBiblionumber GetSubscription GetSubscriptionsFromBiblionumber );
use C4::Search  qw( z3950_search_args enabled_staff_search_views );

use Koha::Biblios;
use Koha::Patrons;
use Koha::RecordProcessor;
use Koha::Virtualshelves;

my $query = CGI->new;
my $dbh   = C4::Context->dbh;

my $biblionumber = $query->param('biblionumber');
$biblionumber = HTML::Entities::encode($biblionumber);

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/ISBDdetail.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $biblio = Koha::Biblios->find($biblionumber);
unless ( $biblionumber && $biblio ) {

    # biblionumber invalid -> report and exit
    $template->param(
        blocking_error => 'unknown_biblionumber',
        biblionumber   => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $record = $biblio->metadata_record( { embed_items => 1, interface => 'intranet' } );
if ( not defined $record ) {

    # biblionumber invalid -> report and exit
    $template->param(
        blocking_error => 'unknown_biblionumber',
        biblionumber   => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $framework = $biblio->frameworkcode;
my $res       = GetISBDView(
    {
        'record'    => $record,
        'template'  => 'intranet',
        'framework' => $framework,
    }
);

if ( $query->cookie("holdfor") ) {
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    $template->param(
        holdfor        => $query->cookie("holdfor"),
        holdfor_patron => $holdfor_patron,
    );
}

if ( $query->cookie("searchToOrder") ) {
    my ( $basketno, $vendorid ) = split( /\//, $query->cookie("searchToOrder") );
    $template->param(
        searchtoorder_basketno => $basketno,
        searchtoorder_vendorid => $vendorid
    );
}

# count of item linked with biblio
my $itemcount = $biblio->items->count;
$template->param( count => $itemcount );
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);

if ($subscriptionsnumber) {
    my $subscriptions     = GetSubscriptionsFromBiblionumber($biblionumber);
    my $subscriptiontitle = $subscriptions->[0]{'bibliotitle'};
    $template->param(
        subscriptionsnumber => $subscriptionsnumber,
        subscriptiontitle   => $subscriptiontitle,
    );
}

# get biblionumbers stored in the cart
my @cart_list;

if ( $query->cookie("intranet_bib_list") ) {
    my $cart_list = $query->cookie("intranet_bib_list");
    @cart_list = split( /\//, $cart_list );
    if ( grep { $_ eq $biblionumber } @cart_list ) {
        $template->param( incart => 1 );
    }
}

my $some_private_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $loggedinuser,
        add_allowed    => 1,
        public         => 0,
    }
);
my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $loggedinuser,
        add_allowed    => 1,
        public         => 1,
    }
);

$template->param(
    add_to_some_private_shelves => $some_private_shelves,
    add_to_some_public_shelves  => $some_public_shelves,
);

$template->param(
    ISBD                => $res,
    biblionumber        => $biblionumber,
    isbdview            => 1,
    z3950_search_params => C4::Search::z3950_search_args( GetBiblioData($biblionumber) ),
    ocoins              => $biblio->get_coins,
    C4::Search::enabled_staff_search_views,
    searchid => scalar $query->param('searchid'),
    biblio   => $biblio,
);

my $holds = $biblio->holds;
$template->param( holdcount => $holds->count );

output_html_with_http_headers $query, $cookie, $template->output;

