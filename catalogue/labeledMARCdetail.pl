#!/usr/bin/perl

# Copyright 2008-2009 LibLime
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
use HTML::Entities;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Biblio qw(
    GetBiblioData
    GetFrameworkCode
    GetMarcStructure
);
use C4::Search  qw( z3950_search_args enabled_staff_search_views );
use C4::Serials qw( CountSubscriptionFromBiblionumber );

use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::Patrons;
use Koha::Virtualshelves;

my $query        = CGI->new;
my $dbh          = C4::Context->dbh;
my $biblionumber = $query->param('biblionumber');
$biblionumber = HTML::Entities::encode($biblionumber);
my $frameworkcode = $query->param('frameworkcode') // GetFrameworkCode($biblionumber);
my $popup         = $query->param('popup');    # if set to 1, then don't insert links, it's just to show the biblio

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/labeledMARCdetail.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $biblio_object = Koha::Biblios->find($biblionumber);    # FIXME Should replace $biblio
unless ($biblio_object) {

    # biblionumber invalid -> report and exit
    $template->param(
        blocking_error => 'unknown_biblionumber',
        biblionumber   => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $record  = $biblio_object->metadata->record;
my $tagslib = GetMarcStructure( 1, $frameworkcode );
my $biblio  = GetBiblioData($biblionumber);

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

#count of item linked
my $itemcount = $biblio_object->items->count;
$template->param(
    count       => $itemcount,
    bibliotitle => $biblio->{title},
);

my $frameworks = Koha::BiblioFrameworks->search( {}, { order_by => ['frameworktext'] } );
$template->param(
    frameworks    => $frameworks,
    frameworkcode => $frameworkcode,
);

my @marc_data;
my $prevlabel = '';
for my $field ( $record->fields ) {
    my $tag = $field->tag;
    next if !exists $tagslib->{$tag}->{lib};
    my $label = $tagslib->{$tag}->{lib};
    if ( $label eq $prevlabel ) {
        $label = '';
    } else {
        $prevlabel = $label;
    }
    my $value =
          $tag < 10
        ? $field->data
        : join ' ', map { $_->[1] } $field->subfields;
    push @marc_data, {
        label => $label,
        value => $value,
    };
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
    marc_data           => \@marc_data,
    biblionumber        => $biblionumber,
    popup               => $popup,
    labeledmarcview     => 1,
    z3950_search_params => C4::Search::z3950_search_args($biblio),
    C4::Search::enabled_staff_search_views,
    subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumber),
    searchid            => scalar $query->param('searchid'),
);

$biblio = Koha::Biblios->find($biblionumber);
my $holds = $biblio->holds;
$template->param( biblio => $biblio, holdcount => $holds->count );

output_html_with_http_headers $query, $cookie, $template->output;
