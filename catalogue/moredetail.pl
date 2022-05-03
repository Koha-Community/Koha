#!/usr/bin/perl

# Copyright 2000-2003 Katipo Communications
# parts copyright 2010 BibLibre
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
use C4::Koha qw( GetAuthorisedValues );
use CGI qw ( -utf8 );
use HTML::Entities;
use C4::Biblio qw( GetBiblioData GetFrameworkCode GetMarcBiblio );
use C4::Items qw( GetHostItemsInfo GetItemsInfo );
use C4::Acquisition qw( GetOrderFromItemnumber GetBasket GetInvoice );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use C4::Search qw( enabled_staff_search_views z3950_search_args );

use Koha::Acquisition::Booksellers;
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Items;
use Koha::Patrons;

my $query=CGI->new;

my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => 'catalogue/moredetail.tt',
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

$template->param(
    updated_exclude_from_local_holds_priority => scalar($query->param('updated_exclude_from_local_holds_priority'))
);

if($query->cookie("holdfor")){ 
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    $template->param(
        holdfor            => $query->cookie("holdfor"),
        holdfor_patron     => $holdfor_patron,
        holdfor_cardnumber => $holdfor_patron->cardnumber,
    );
}

if( $query->cookie("searchToOrder") ){
    my ( $basketno, $vendorid ) = split( /\//, $query->cookie("searchToOrder") );
    $template->param(
        searchtoorder_basketno => $basketno,
        searchtoorder_vendorid => $vendorid
    );
}

# get variables
my $biblionumber;
my $itemnumber;
if( $query->param('itemnumber') && !$query->param('biblionumber') ){
    $itemnumber = $query->param('itemnumber');
    my $item = Koha::Items->find( $itemnumber );
    $biblionumber = $item->biblionumber;
} else {
    $biblionumber = $query->param('biblionumber');
}

$biblionumber = HTML::Entities::encode($biblionumber);
my $title=$query->param('title');
my $bi=$query->param('bi');
$bi = $biblionumber unless $bi;
$itemnumber = $query->param('itemnumber');
my $data = &GetBiblioData($biblionumber);
my $dewey = $data->{'dewey'};
my $showallitems = $query->param('showallitems');

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);

# FIXME Dewey is a string, not a number, & we should use a function
# $dewey =~ s/0+$//;
# if ($dewey eq "000.") { $dewey = "";};
# if ($dewey < 10){$dewey='00'.$dewey;}
# if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
# if ($dewey <= 0){
#      $dewey='';
# }
# $dewey=~ s/\.$//;
# $data->{'dewey'}=$dewey;

my $fw = GetFrameworkCode($biblionumber);
my @all_items= GetItemsInfo($biblionumber);
my @items;
my $patron = Koha::Patrons->find( $loggedinuser );
for my $itm (@all_items) {
    push @items, $itm unless ( $itm->{itemlost} && 
                               $patron->category->hidelostitems &&
                               !$showallitems && 
                               ($itemnumber != $itm->{itemnumber}));
}

my $record=GetMarcBiblio({ biblionumber => $biblionumber });

output_and_exit( $query, $cookie, $template, 'unknown_biblio')
    unless $record;

my $hostrecords;
# adding items linked via host biblios
my @hostitems = GetHostItemsInfo($record);
if (@hostitems){
        $hostrecords =1;
        push (@items,@hostitems);
}

my $biblio = Koha::Biblios->find( $biblionumber );

my $totalcount=@all_items;
my $showncount=@items;
my $hiddencount = $totalcount - $showncount;
$data->{'count'}=$totalcount;
$data->{'showncount'}=$showncount;
$data->{'hiddencount'}=$hiddencount;  # can be zero

my $ccodes =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $fw, kohafield => 'items.ccode' } ) };
my $copynumbers =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $fw, kohafield => 'items.copynumber' } ) };

my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };

$data->{'itemtypename'} = $itemtypes->{ $data->{'itemtype'} }->{'translated_description'}
  if $data->{itemtype} && exists $itemtypes->{ $data->{itemtype} };
foreach ( keys %{$data} ) {
    $template->param( "$_" => defined $data->{$_} ? $data->{$_} : '' );
}

($itemnumber) and @items = (grep {$_->{'itemnumber'} == $itemnumber} @items);
foreach my $item (@items){
    $item->{object} = Koha::Items->find( $item->{itemnumber} );
    $item->{'collection'}              = $ccodes->{ $item->{ccode} } if $ccodes && $item->{ccode} && exists $ccodes->{ $item->{ccode} };
    $item->{'itype'}                   = $itemtypes->{ $item->{'itype'} }->{'translated_description'} if exists $itemtypes->{ $item->{'itype'} };
    $item->{'replacementprice'}        = $item->{'replacementprice'};
    if ( defined $item->{'copynumber'} ) {
        $item->{'displaycopy'} = 1;
        if ( defined $copynumbers->{ $item->{'copynumber'} } ) {
            $item->{'copyvol'} = $copynumbers->{ $item->{'copynumber'} }
        }
        else {
            $item->{'copyvol'} = $item->{'copynumber'};
        }
    }

    # item has a host number if its biblio number does not match the current bib
    if ($item->{biblionumber} ne $biblionumber){
        $item->{hostbiblionumber} = $item->{biblionumber};
        $item->{hosttitle} = GetBiblioData($item->{biblionumber})->{title};
    }

    my $order  = GetOrderFromItemnumber( $item->{'itemnumber'} );
    $item->{'ordernumber'}             = $order->{'ordernumber'};
    $item->{'basketno'}                = $order->{'basketno'};
    $item->{'orderdate'}               = $order->{'entrydate'};
    if ($item->{'basketno'}){
	    my $basket = GetBasket($item->{'basketno'});
        my $bookseller = Koha::Acquisition::Booksellers->find( $basket->{booksellerid} );
        $item->{'vendor'} = $bookseller->name;
    }
    $item->{'invoiceid'}               = $order->{'invoiceid'};
    if($item->{invoiceid}) {
        my $invoice = GetInvoice($item->{invoiceid});
        $item->{invoicenumber} = $invoice->{invoicenumber} if $invoice;
    }
    $item->{'datereceived'}            = $order->{'datereceived'};

    if ($item->{notforloantext} or $item->{itemlost} or $item->{damaged} or $item->{withdrawn}) {
        $item->{status_advisory} = 1;
    }

    # Add paidfor info
    if ( $item->{itemlost} ) {
        my $accountlines = Koha::Account::Lines->search(
            {
                itemnumber        => $item->{itemnumber},
                debit_type_code   => 'LOST',
                status            => [ undef, { '<>' => 'RETURNED' } ],
                amountoutstanding => 0
            },
            {
                order_by => { '-desc' => 'date' },
                rows     => 1
            }
        );

        if ( my $accountline = $accountlines->next ) {
            my $payment_offsets = $accountline->debit_offsets(
                {
                    credit_id => { '!=' => undef }, # it is not the debit itself
                    'credit.credit_type_code' =>
                      { '!=' => [ 'Writeoff', 'Forgiven' ] },
                },
                { join => 'credit', order_by => { '-desc' => 'created_on' } }
            );

            if ($payment_offsets->count) {
                my $patron = $accountline->patron;
                my $payment_offset = $payment_offsets->next;
                $item->{paidfor} = { patron => $patron, created_on => $payment_offset->created_on };
            }
        }
    }

    if (C4::Context->preference("IndependentBranches")) {
        #verifying rights
        my $userenv = C4::Context->userenv();
        unless (C4::Context->IsSuperLibrarian() or ($userenv->{'branch'} eq $item->{'homebranch'})) {
                $item->{'nomod'}=1;
        }
    }
    if ($item->{'datedue'}) {
        $item->{'issue'}= 1;
    } else {
        $item->{'issue'}= 0;
    }

    if ( $item->{'borrowernumber'} ) {
        my $curr_borrower = Koha::Patrons->find( $item->{borrowernumber} );
        $item->{patron} = $curr_borrower;
    }
}

my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.itemlost', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
if ( $mss->count ) {
    $template->param( itemlostloop => GetAuthorisedValues( $mss->next->authorised_value ) );
}
$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.damaged', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
if ( $mss->count ) {
    $template->param( itemdamagedloop => GetAuthorisedValues( $mss->next->authorised_value ) );
}
$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.withdrawn', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
if ( $mss->count ) {
    $template->param( itemwithdrawnloop => GetAuthorisedValues( $mss->next->authorised_value) );
}

$template->param(count => $data->{'count'},
	subscriptionsnumber => $subscriptionsnumber,
    subscriptiontitle   => $data->{title},
	C4::Search::enabled_staff_search_views,
);

# get biblionumbers stored in the cart
my @cart_list;

if($query->cookie("intranet_bib_list")){
    my $cart_list = $query->cookie("intranet_bib_list");
    @cart_list = split(/\//, $cart_list);
    if ( grep {$_ eq $biblionumber} @cart_list) {
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
    ITEM_DATA           => \@items,
    moredetailview      => 1,
    loggedinuser        => $loggedinuser,
    biblionumber        => $biblionumber,
    biblioitemnumber    => $bi,
    itemnumber          => $itemnumber,
    z3950_search_params => C4::Search::z3950_search_args(GetBiblioData($biblionumber)),
    biblio              => $biblio,
);
$template->param(ONLY_ONE => 1) if ( $itemnumber && $showncount != @items );
$template->{'VARS'}->{'searchid'} = $query->param('searchid');

my $holds = $biblio->holds;
$template->param( holdcount => $holds->count );

output_html_with_http_headers $query, $cookie, $template->output;

