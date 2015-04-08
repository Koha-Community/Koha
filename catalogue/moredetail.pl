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


use strict;
#use warnings; FIXME - Bug 2505
use C4::Koha;
use CGI;
use C4::Biblio;
use C4::Items;
use C4::Branch;
use C4::Acquisition;
use C4::Bookseller qw(GetBookSellerFromId);
use C4::Output;
use C4::Auth;
use C4::Serials;
use C4::Circulation;  # to use itemissues
use C4::Members; # to use GetMember
use C4::Search;		# enabled_staff_search_views
use C4::Members qw/GetHideLostItemsPreference/;
use C4::Reserves qw(GetReservesFromBiblionumber);
use Koha::DateUtils;

my $query=new CGI;

# FIXME  subject is not exported to the template?
my $subject=$query->param('subject');

# if its a subject we need to use the subject.tt
my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => ( $subject
                                ? 'catalogue/subject.tt'
                                : 'catalogue/moredetail.tt'),
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

if($query->cookie("holdfor")){ 
    my $holdfor_patron = GetMember('borrowernumber' => $query->cookie("holdfor"));
    $template->param(
        holdfor => $query->cookie("holdfor"),
        holdfor_surname => $holdfor_patron->{'surname'},
        holdfor_firstname => $holdfor_patron->{'firstname'},
        holdfor_cardnumber => $holdfor_patron->{'cardnumber'},
    );
}

my $hidepatronname = C4::Context->preference("HidePatronName");

# get variables

my $biblionumber=$query->param('biblionumber');
my $title=$query->param('title');
my $bi=$query->param('bi');
$bi = $biblionumber unless $bi;
my $itemnumber = $query->param('itemnumber');
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
for my $itm (@all_items) {
    push @items, $itm unless ( $itm->{itemlost} && 
                               GetHideLostItemsPreference($loggedinuser) &&
                               !$showallitems && 
                               ($itemnumber != $itm->{itemnumber}));
}

my $record=GetMarcBiblio($biblionumber);

my $hostrecords;
# adding items linked via host biblios
my @hostitems = GetHostItemsInfo($record);
if (@hostitems){
        $hostrecords =1;
        push (@items,@hostitems);
}

my $subtitle = GetRecordValue('subtitle', $record, $fw);

my $totalcount=@all_items;
my $showncount=@items;
my $hiddencount = $totalcount - $showncount;
$data->{'count'}=$totalcount;
$data->{'showncount'}=$showncount;
$data->{'hiddencount'}=$hiddencount;  # can be zero

my $ccodes= GetKohaAuthorisedValues('items.ccode',$fw);
my $copynumbers = GetKohaAuthorisedValues('items.copynumber',$fw);
my $itemtypes = GetItemTypes;

$data->{'itemtypename'} = $itemtypes->{$data->{'itemtype'}}->{'description'};
$data->{'rentalcharge'} = sprintf( "%.2f", $data->{'rentalcharge'} );
foreach ( keys %{$data} ) {
    $template->param( "$_" => defined $data->{$_} ? $data->{$_} : '' );
}

($itemnumber) and @items = (grep {$_->{'itemnumber'} == $itemnumber} @items);
foreach my $item (@items){
    $item->{itemlostloop}= GetAuthorisedValues(GetAuthValCode('items.itemlost',$fw),$item->{itemlost}) if GetAuthValCode('items.itemlost',$fw);
    $item->{itemdamagedloop}= GetAuthorisedValues(GetAuthValCode('items.damaged',$fw),$item->{damaged}) if GetAuthValCode('items.damaged',$fw);
    $item->{'collection'}              = $ccodes->{ $item->{ccode} } if ($ccodes);
    $item->{'itype'}                   = $itemtypes->{ $item->{'itype'} }->{'description'};
    $item->{'replacementprice'}        = sprintf( "%.2f", $item->{'replacementprice'} );
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
	    my $bookseller = GetBookSellerFromId($basket->{'booksellerid'});
	    $item->{'vendor'} = $bookseller->{'name'};
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

    if (C4::Context->preference("IndependentBranches")) {
        #verifying rights
        my $userenv = C4::Context->userenv();
        unless (C4::Context->IsSuperLibrarian() or ($userenv->{'branch'} eq $item->{'homebranch'})) {
                $item->{'nomod'}=1;
        }
    }
    $item->{'homebranchname'} = GetBranchName($item->{'homebranch'});
    $item->{'holdingbranchname'} = GetBranchName($item->{'holdingbranch'});
    if ($item->{'datedue'}) {
        $item->{'issue'}= 1;
    } else {
        $item->{'issue'}= 0;
    }

    unless ($hidepatronname) {
        if ( $item->{'borrowernumber'} ) {
            my $curr_borrower = GetMember('borrowernumber' => $item->{'borrowernumber'} );
            $item->{borrowerfirstname} = $curr_borrower->{'firstname'};
            $item->{borrowersurname} = $curr_borrower->{'surname'};
        }
    }

}
$template->param(count => $data->{'count'},
	subscriptionsnumber => $subscriptionsnumber,
    subscriptiontitle   => $data->{title},
	C4::Search::enabled_staff_search_views,
);

$template->param(
    ITEM_DATA           => \@items,
    moredetailview      => 1,
    loggedinuser        => $loggedinuser,
    biblionumber        => $biblionumber,
    biblioitemnumber    => $bi,
    itemnumber          => $itemnumber,
    z3950_search_params => C4::Search::z3950_search_args(GetBiblioData($biblionumber)),
    subtitle            => $subtitle,
    hidepatronname      => $hidepatronname,
);
$template->param(ONLY_ONE => 1) if ( $itemnumber && $showncount != @items );
$template->{'VARS'}->{'searchid'} = $query->param('searchid');

my @allorders_using_biblio = GetOrdersByBiblionumber ($biblionumber);
my @deletedorders_using_biblio;
my @orders_using_biblio;
my @baskets_orders;
my @baskets_deletedorders;

foreach my $myorder (@allorders_using_biblio) {
    my $basket = $myorder->{'basketno'};
    if ((defined $myorder->{'datecancellationprinted'}) and  ($myorder->{'datecancellationprinted'} ne '0000-00-00') ){
        push @deletedorders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_deletedorders)){
            push @baskets_deletedorders,$myorder->{'basketno'};
        }
    }
    else {
        push @orders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_orders)){
            push @baskets_orders,$myorder->{'basketno'};
            }
    }
}

my $count_orders_using_biblio = scalar @orders_using_biblio ;
$template->param (countorders => $count_orders_using_biblio);

my $count_deletedorders_using_biblio = scalar @deletedorders_using_biblio ;
$template->param (countdeletedorders => $count_deletedorders_using_biblio);

my $holds = GetReservesFromBiblionumber({ biblionumber => $biblionumber, all_dates => 1 });
my $holdcount = scalar( @$holds );
$template->param( holdcount => scalar ( @$holds ) );

output_html_with_http_headers $query, $cookie, $template->output;

