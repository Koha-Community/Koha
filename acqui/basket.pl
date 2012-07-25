#!/usr/bin/perl

#script to show display basket of orders

# Copyright 2000 - 2004 Katipo
# Copyright 2008 - 2009 BibLibre SARL
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

use strict;
use warnings;
use C4::Auth;
use C4::Koha;
use C4::Output;
use CGI;
use C4::Acquisition;
use C4::Budgets;
use C4::Bookseller qw( GetBookSellerFromId);
use C4::Debug;
use C4::Biblio;
use C4::Members qw/GetMember/;  #needed for permissions checking for changing basketgroup of a basket
use C4::Items;
use C4::Suggestions;
use Date::Calc qw/Add_Delta_Days/;

=head1 NAME

basket.pl

=head1 DESCRIPTION

 This script display all informations about basket for the supplier given
 on input arg.  Moreover, it allows us to add a new order for this supplier from
 an existing record, a suggestion or a new record.

=head1 CGI PARAMETERS

=over 4

=item $basketno

The basket number.

=item booksellerid

the supplier this script have to display the basket.

=item order

=back

=cut

my $query        = new CGI;
my $basketno     = $query->param('basketno');
my $booksellerid = $query->param('booksellerid');

my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => "acqui/basket.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

my $basket = GetBasket($basketno);

# FIXME : what about the "discount" percentage?
# FIXME : the query->param('booksellerid') below is probably useless. The bookseller is always known from the basket
# if no booksellerid in parameter, get it from basket
# warn "=>".$basket->{booksellerid};
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my ($bookseller) = GetBookSellerFromId($booksellerid);
my $op = $query->param('op');
if (!defined $op) {
    $op = q{};
}

my $confirm_pref= C4::Context->preference("BasketConfirmations") || '1';
$template->param( skip_confirm_reopen => 1) if $confirm_pref eq '2';

if ( $op eq 'delete_confirm' ) {
    my $basketno = $query->param('basketno');
    DelBasket($basketno);
    $template->param( delete_confirmed => 1 );
} elsif ( !$bookseller ) {
    $template->param( NO_BOOKSELLER => 1 );
} elsif ( $op eq 'del_basket') {
    $template->param( delete_confirm => 1 );
    if ( C4::Context->preference("IndependantBranches") ) {
        my $userenv = C4::Context->userenv;
        unless ( $userenv->{flags} == 1 ) {
            my $validtest = ( $basket->{creationdate} eq '' )
              || ( $userenv->{branch} eq $basket->{branch} )
              || ( $userenv->{branch} eq '' )
              || ( $basket->{branch}  eq '' );
            unless ($validtest) {
                print $query->redirect("../mainpage.pl");
                exit 1;
            }
        }
    }
    $basket->{creationdate} = ""            unless ( $basket->{creationdate} );
    $basket->{authorisedby} = $loggedinuser unless ( $basket->{authorisedby} );
    my $contract = &GetContract($basket->{contractnumber});
    $template->param(
        basketno             => $basketno,
        basketname           => $basket->{'basketname'},
        basketnote           => $basket->{note},
        basketbooksellernote => $basket->{booksellernote},
        basketcontractno     => $basket->{contractnumber},
        basketcontractname   => $contract->{contractname},
        creationdate         => $basket->{creationdate},
        authorisedby         => $basket->{authorisedby},
        authorisedbyname     => $basket->{authorisedbyname},
        closedate            => $basket->{closedate},
        deliveryplace        => $basket->{deliveryplace},
        billingplace         => $basket->{billingplace},
        active               => $bookseller->{'active'},
        booksellerid         => $bookseller->{'id'},
        name                 => $bookseller->{'name'},
        address1             => $bookseller->{'address1'},
        address2             => $bookseller->{'address2'},
        address3             => $bookseller->{'address3'},
        address4             => $bookseller->{'address4'},
      );
} elsif ($op eq 'attachbasket' && $template->{'VARS'}->{'CAN_user_acquisition_group_manage'} == 1) {
      print $query->redirect('/cgi-bin/koha/acqui/basketgroup.pl?basketno=' . $basket->{'basketno'} . '&op=attachbasket&booksellerid=' . $booksellerid);
    # check if we have to "close" a basket before building page
} elsif ($op eq 'export') {
    print $query->header(
        -type       => 'text/csv',
        -attachment => 'basket' . $basket->{'basketno'} . '.csv',
    );
    print GetBasketAsCSV($query->param('basketno'), $query);
    exit;
} elsif ($op eq 'close') {
    my $confirm = $query->param('confirm') || $confirm_pref eq '2';
    if ($confirm) {
        my $basketno = $query->param('basketno');
        my $booksellerid = $query->param('booksellerid');
        $basketno =~ /^\d+$/ and CloseBasket($basketno);
        # if requested, create basket group, close it and attach the basket
        if ($query->param('createbasketgroup')) {
            my $branchcode;
            if(C4::Context->userenv and C4::Context->userenv->{'branch'}
              and C4::Context->userenv->{'branch'} ne "NO_LIBRARY_SET") {
                $branchcode = C4::Context->userenv->{'branch'};
            }
            my $basketgroupid = NewBasketgroup( { name => $basket->{basketname},
                            booksellerid => $booksellerid,
                            deliveryplace => $branchcode,
                            billingplace => $branchcode,
                            closed => 1,
                            });
            ModBasket( { basketno => $basketno,
                         basketgroupid => $basketgroupid } );
            print $query->redirect('/cgi-bin/koha/acqui/basketgroup.pl?booksellerid='.$booksellerid.'&closed=1');
        } else {
            print $query->redirect('/cgi-bin/koha/acqui/booksellers.pl?booksellerid=' . $booksellerid);
        }
        exit;
    } else {
    $template->param(confirm_close => "1",
            booksellerid    => $booksellerid,
            basketno        => $basket->{'basketno'},
                basketname      => $basket->{'basketname'},
            basketgroupname => $basket->{'basketname'});
        
    }
} elsif ($op eq 'reopen') {
    my $basket;
    $basket->{basketno} = $query->param('basketno');
    $basket->{closedate} = undef;
    ModBasket($basket);
    print $query->redirect('/cgi-bin/koha/acqui/basket.pl?basketno='.$basket->{'basketno'})
} else {
    # get librarian branch...
    if ( C4::Context->preference("IndependantBranches") ) {
        my $userenv = C4::Context->userenv;
        unless ( $userenv->{flags} == 1 ) {
            my $validtest = ( $basket->{creationdate} eq '' )
              || ( $userenv->{branch} eq $basket->{branch} )
              || ( $userenv->{branch} eq '' )
              || ( $basket->{branch}  eq '' );
            unless ($validtest) {
                print $query->redirect("../mainpage.pl");
                exit 1;
            }
        }
    }
#if the basket is closed,and the user has the permission to edit basketgroups, display a list of basketgroups
    my $basketgroups;
    my $member = GetMember(borrowernumber => $loggedinuser);
    if ($basket->{closedate} && haspermission({ acquisition => 'group_manage'} )) {
        $basketgroups = GetBasketgroups($basket->{booksellerid});
        for my $bg ( @{$basketgroups} ) {
            if ($basket->{basketgroupid} && $basket->{basketgroupid} == $bg->{id}){
                $bg->{default} = 1;
            }
        }
        my %emptygroup = ( id   =>   undef,
                           name =>   "No group");
        if ( ! $basket->{basketgroupid} ) {
            $emptygroup{default} = 1;
            $emptygroup{nogroup} = 1;
        }
        unshift( @$basketgroups, \%emptygroup );
    }

    # if the basket is closed, calculate estimated delivery date
    my $estimateddeliverydate;
    if( $basket->{closedate} ) {
        my ($year, $month, $day) = ($basket->{closedate} =~ /(\d+)-(\d+)-(\d+)/);
        ($year, $month, $day) = Add_Delta_Days($year, $month, $day, $bookseller->{deliverytime});
        $estimateddeliverydate = "$year-$month-$day";
    }

    # if new basket, pre-fill infos
    $basket->{creationdate} = ""            unless ( $basket->{creationdate} );
    $basket->{authorisedby} = $loggedinuser unless ( $basket->{authorisedby} );
    $debug
      and warn sprintf
      "loggedinuser: $loggedinuser; creationdate: %s; authorisedby: %s",
      $basket->{creationdate}, $basket->{authorisedby};

    #to get active currency
    my $cur = GetCurrency();


    my @results = GetOrders( $basketno );
    my @books_loop;

    my @book_foot_loop;
    my %foot;
    my $total_quantity = 0;
    my $total_gste = 0;
    my $total_gsti = 0;
    my $total_gstvalue = 0;
    for my $order (@results) {
        my $line = get_order_infos( $order, $bookseller);
        if ( $line->{uncertainprice} ) {
            $template->param( uncertainprices => 1 );
        }

        push @books_loop, $line;

        $foot{$$line{gstgsti}}{gstgsti} = $$line{gstgsti};
        $foot{$$line{gstgsti}}{gstvalue} += $$line{gstvalue};
        $total_gstvalue += $$line{gstvalue};
        $foot{$$line{gstgsti}}{quantity}  += $$line{quantity};
        $total_quantity += $$line{quantity};
        $foot{$$line{gstgsti}}{totalgste} += $$line{totalgste};
        $total_gste += $$line{totalgste};
        $foot{$$line{gstgsti}}{totalgsti} += $$line{totalgsti};
        $total_gsti += $$line{totalgsti};
    }

    push @book_foot_loop, map {$_} values %foot;

    # Get cancelled orders
    @results = GetCancelledOrders($basketno);
    my @cancelledorders_loop;
    for my $order (@results) {
        my $line = get_order_infos( $order, $bookseller);
        push @cancelledorders_loop, $line;
    }

    my $contract = &GetContract($basket->{contractnumber});
    my @orders = GetOrders($basketno);

    if ($basket->{basketgroupid}){
        my $basketgroup = GetBasketgroup($basket->{basketgroupid});
        for my $key (keys %$basketgroup ){
            $basketgroup->{"basketgroup$key"} = delete $basketgroup->{$key};
        }
        $basketgroup->{basketgroupdeliveryplace} = C4::Branch::GetBranchName( $basketgroup->{basketgroupdeliveryplace} );
        $basketgroup->{basketgroupbillingplace} = C4::Branch::GetBranchName( $basketgroup->{basketgroupbillingplace} );
        $template->param(%$basketgroup);
    }
    my $borrower= GetMember('borrowernumber' => $loggedinuser);
    my $budgets = GetBudgetHierarchy;
    my $has_budgets = 0;
    foreach my $r (@{$budgets}) {
        if (!defined $r->{budget_amount} || $r->{budget_amount} == 0) {
            next;
        }
        next unless (CanUserUseBudget($loggedinuser, $r, $userflags));

        $has_budgets = 1;
        last;
    }

    my @cancelledorders = GetCancelledOrders($basketno);
    foreach (@cancelledorders) {
        $_->{'line_total'} = sprintf("%.2f", $_->{'ecost'} * $_->{'quantity'});
    }

    $template->param(
        basketno             => $basketno,
        basketname           => $basket->{'basketname'},
        basketnote           => $basket->{note},
        basketbooksellernote => $basket->{booksellernote},
        basketcontractno     => $basket->{contractnumber},
        basketcontractname   => $contract->{contractname},
        creationdate         => $basket->{creationdate},
        authorisedby         => $basket->{authorisedby},
        authorisedbyname     => $basket->{authorisedbyname},
        closedate            => $basket->{closedate},
        estimateddeliverydate=> $estimateddeliverydate,
        deliveryplace        => C4::Branch::GetBranchName( $basket->{deliveryplace} ),
        billingplace         => C4::Branch::GetBranchName( $basket->{billingplace} ),
        active               => $bookseller->{'active'},
        booksellerid         => $bookseller->{'id'},
        name                 => $bookseller->{'name'},
        books_loop           => \@books_loop,
        book_foot_loop       => \@book_foot_loop,
        cancelledorders_loop => \@cancelledorders,
        total_quantity       => $total_quantity,
        total_gste           => sprintf( "%.2f", $total_gste ),
        total_gsti           => sprintf( "%.2f", $total_gsti ),
        total_gstvalue       => sprintf( "%.2f", $total_gstvalue ),
        currency             => $cur->{'currency'},
        listincgst           => $bookseller->{listincgst},
        basketgroups         => $basketgroups,
        grouped              => $basket->{basketgroupid},
        unclosable           => @orders ? 0 : 1, 
        has_budgets          => $has_budgets,
    );
}

sub get_order_infos {
    my $order = shift;
    my $bookseller = shift;
    my $qty = $order->{'quantity'} || 0;
    if ( !defined $order->{quantityreceived} ) {
        $order->{quantityreceived} = 0;
    }
    my $budget = GetBudget( $order->{'budget_id'} );

    my %line = %{ $order };
    $line{order_received} = ( $qty == $order->{'quantityreceived'} );
    $line{basketno}       = $basketno;
    $line{budget_name}    = $budget->{budget_name};
    $line{rrp} = ConvertCurrency( $order->{'currency'}, $line{rrp} ); # FIXME from comm
    if ( $bookseller->{'listincgst'} ) {
        $line{rrpgsti} = sprintf( "%.2f", $line{rrp} );
        $line{gstgsti} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{rrpgste} = sprintf( "%.2f", $line{rrp} / ( 1 + ( $line{gstgsti} / 100 ) ) );
        $line{gstgste} = sprintf( "%.2f", $line{gstgsti} / ( 1 + ( $line{gstgsti} / 100 ) ) );
        $line{ecostgsti} = sprintf( "%.2f", $line{ecost} );
        $line{ecostgste} = sprintf( "%.2f", $line{ecost} / ( 1 + ( $line{gstgsti} / 100 ) ) );
        $line{gstvalue} = sprintf( "%.2f", ( $line{ecostgsti} - $line{ecostgste} ) * $line{quantity});
        $line{totalgste} = sprintf( "%.2f", $order->{quantity} * $line{ecostgste} );
        $line{totalgsti} = sprintf( "%.2f", $order->{quantity} * $line{ecostgsti} );
    } else {
        $line{rrpgsti} = sprintf( "%.2f", $line{rrp} * ( 1 + ( $line{gstrate} ) ) );
        $line{rrpgste} = sprintf( "%.2f", $line{rrp} );
        $line{gstgsti} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{gstgste} = sprintf( "%.2f", $line{gstrate} * 100 );
        $line{ecostgsti} = sprintf( "%.2f", $line{ecost} * ( 1 + ( $line{gstrate} ) ) );
        $line{ecostgste} = sprintf( "%.2f", $line{ecost} );
        $line{gstvalue} = sprintf( "%.2f", ( $line{ecostgsti} - $line{ecostgste} ) * $line{quantity});
        $line{totalgste} = sprintf( "%.2f", $order->{quantity} * $line{ecostgste} );
        $line{totalgsti} = sprintf( "%.2f", $order->{quantity} * $line{ecostgsti} );
    }

    if ( $line{uncertainprice} ) {
        $line{rrpgste} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
    } else {
        $line{'title'} = "Deleted bibliographic notice, can't find title.";
    }

    my $biblionumber = $order->{'biblionumber'};
    my $countbiblio = CountBiblioInOrders($biblionumber);
    my $ordernumber = $order->{'ordernumber'};
    my @subscriptions = GetSubscriptionsId ($biblionumber);
    my $itemcount = GetItemsCount($biblionumber);
    my $holds  = GetHolds ($biblionumber);
    my @items = GetItemnumbersFromOrder( $ordernumber );
    my $itemholds;
    foreach my $item (@items){
        my $nb = GetItemHolds($biblionumber, $item);
        if ($nb){
            $itemholds += $nb;
        }
    }
    # if the biblio is not in other orders and if there is no items elsewhere and no subscriptions and no holds we can then show the link "Delete order and Biblio" see bug 5680
    $line{can_del_bib}          = 1 if $countbiblio <= 1 && $itemcount == scalar @items && !(@subscriptions) && !($holds);
    $line{items}                = ($itemcount) - (scalar @items);
    $line{left_item}            = 1 if $line{items} >= 1;
    $line{left_biblio}          = 1 if $countbiblio > 1;
    $line{biblios}              = $countbiblio - 1;
    $line{left_subscription}    = 1 if scalar @subscriptions >= 1;
    $line{subscriptions}        = scalar @subscriptions;
    ($holds >= 1) ? $line{left_holds} = 1 : $line{left_holds} = 0;
    $line{left_holds_on_order}  = 1 if $line{left_holds}==1 && ($line{items} == 0 || $itemholds );
    $line{holds}                = $holds;
    $line{holds_on_order}       = $itemholds?$itemholds:$holds if $line{left_holds_on_order};


    my $suggestion   = GetSuggestionInfoFromBiblionumber($line{biblionumber});
    $line{suggestionid}         = $$suggestion{suggestionid};
    $line{surnamesuggestedby}   = $$suggestion{surnamesuggestedby};
    $line{firstnamesuggestedby} = $$suggestion{firstnamesuggestedby};

    return \%line;
}

output_html_with_http_headers $query, $cookie, $template->output;
