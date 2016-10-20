#!/usr/bin/perl

#script to show display basket of orders

# Copyright 2000 - 2004 Katipo
# Copyright 2008 - 2009 BibLibre SARL
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
use C4::Auth;
use C4::Koha;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Acquisition;
use C4::Budgets;
use C4::Contract;
use C4::Debug;
use C4::Biblio;
use C4::Members qw/GetMember/;  #needed for permissions checking for changing basketgroup of a basket
use C4::Items;
use C4::Suggestions;
use Koha::Libraries;
use C4::Letters qw/SendAlerts/;
use Date::Calc qw/Add_Delta_Days/;
use Koha::Database;
use Koha::EDI qw( create_edi_order get_edifact_ean );

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
our $basketno     = $query->param('basketno');
my $ean          = $query->param('ean');
my $booksellerid = $query->param('booksellerid');
my $duplinbatch =  $query->param('duplinbatch');

my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => "acqui/basket.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

my $basket = GetBasket($basketno);
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $booksellerid });
my $schema = Koha::Database->new()->schema();
my $rs = $schema->resultset('VendorEdiAccount')->search(
    { vendor_id => $booksellerid, } );
$template->param( ediaccount => ($rs->count > 0));

unless (CanUserManageBasket($loggedinuser, $basket, $userflags)) {
    $template->param(
        cannot_manage_basket => 1,
        basketno => $basketno,
        basketname => $basket->{basketname},
        booksellerid => $booksellerid,
        name => $bookseller->{name}
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

# FIXME : what about the "discount" percentage?
# FIXME : the query->param('booksellerid') below is probably useless. The bookseller is always known from the basket
# if no booksellerid in parameter, get it from basket
# warn "=>".$basket->{booksellerid};
my $op = $query->param('op') // 'list';

my $confirm_pref= C4::Context->preference("BasketConfirmations") || '1';
$template->param( skip_confirm_reopen => 1) if $confirm_pref eq '2';

my @messages;

if ( $op eq 'delete_confirm' ) {
    my $basketno = $query->param('basketno');
    my $delbiblio = $query->param('delbiblio');
    my @orders = GetOrders($basketno);
#Delete all orders included in that basket, and all items received.
    foreach my $myorder (@orders){
        DelOrder($myorder->{biblionumber},$myorder->{ordernumber});
    }
# if $delbiblio = 1, delete the records if possible
    if ((defined $delbiblio)and ($delbiblio ==1)){
        my @cannotdelbiblios ;
        foreach my $myorder (@orders){
            my $biblionumber = $myorder->{'biblionumber'};
            my $countbiblio = CountBiblioInOrders($biblionumber);
            my $ordernumber = $myorder->{'ordernumber'};
            my $subscriptions = scalar GetSubscriptionsId ($biblionumber);
            my $itemcount = GetItemsCount($biblionumber);
            my $error;
            if ($countbiblio == 0 && $itemcount == 0 && $subscriptions == 0) {
                $error = DelBiblio($myorder->{biblionumber}) }
            else {
                push @cannotdelbiblios, {biblionumber=> ($myorder->{biblionumber}),
                                         title=> $myorder->{'title'},
                                         author=> $myorder->{'author'},
                                         countbiblio=> $countbiblio,
                                         itemcount=>$itemcount,
                                         subscriptions=>$subscriptions};
            }
            if ($error) {
                push @cannotdelbiblios, {biblionumber=> ($myorder->{biblionumber}),
                                         title=> $myorder->{'title'},
                                         author=> $myorder->{'author'},
                                         othererror=> $error};
            }
        }
        $template->param( cannotdelbiblios => \@cannotdelbiblios );
    }
 # delete the basket
    DelBasket($basketno,);
    $template->param( delete_confirmed => 1 );
} elsif ( !$bookseller ) {
    $template->param( NO_BOOKSELLER => 1 );
} elsif ($op eq 'export') {
    print $query->header(
        -type       => 'text/csv',
        -attachment => 'basket' . $basket->{'basketno'} . '.csv',
    );
    print GetBasketAsCSV($query->param('basketno'), $query);
    exit;
} elsif ($op eq 'email') {
    my $err = eval {
        SendAlerts( 'orderacquisition', $query->param('basketno'), 'ACQORDER' );
    };
    if ( $@ ) {
        push @messages, { type => 'error', code => $@ };
    } elsif ( ref $err and exists $err->{error} ) {
        push @messages, { type => 'error', code => $err->{error} };
    } else {
        push @messages, { type => 'message', code => 'email_sent' };
    }

    $op = 'list';
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
    $template->param(
        confirm_close   => "1",
        booksellerid    => $booksellerid,
        basketno        => $basket->{'basketno'},
        basketname      => $basket->{'basketname'},
        basketgroupname => $basket->{'basketname'},
    );
    }
} elsif ($op eq 'reopen') {
    ReopenBasket($query->param('basketno'));
    print $query->redirect('/cgi-bin/koha/acqui/basket.pl?basketno='.$basket->{'basketno'})
}
elsif ( $op eq 'ediorder' ) {
    edi_close_and_order()
} elsif ( $op eq 'mod_users' ) {
    my $basketusers_ids = $query->param('users_ids');
    my @basketusers = split( /:/, $basketusers_ids );
    ModBasketUsers($basketno, @basketusers);
    print $query->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=$basketno");
    exit;
} elsif ( $op eq 'mod_branch' ) {
    my $branch = $query->param('branch');
    $branch = undef if(defined $branch and $branch eq '');
    ModBasket({
        basketno => $basket->{basketno},
        branch   => $branch
    });
    print $query->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=$basketno");
    exit;
}

if ( $op eq 'list' ) {
    my @branches_loop;
    # get librarian branch...
    if ( C4::Context->preference("IndependentBranches") ) {
        my $userenv = C4::Context->userenv;
        unless ( C4::Context->IsSuperLibrarian() ) {
            my $validtest = ( $basket->{creationdate} eq '' )
              || ( $userenv->{branch} eq $basket->{branch} )
              || ( $userenv->{branch} eq '' )
              || ( $basket->{branch}  eq '' );
            unless ($validtest) {
                print $query->redirect("../mainpage.pl");
                exit 0;
            }
        }

        if (!defined $basket->{branch} or $basket->{branch} eq $userenv->{branch}) {
            push @branches_loop, {
                branchcode => $userenv->{branch},
                branchname => $userenv->{branchname},
                selected => 1,
            };
        }
    } else {
        # get branches
        my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
        foreach my $branch (@$branches) {
            my $selected = 0;
            if (defined $basket->{branch}) {
                $selected = 1 if $branch->{branchcode} eq $basket->{branch};
            } else {
                $selected = 1 if $branch->{branchcode} eq C4::Context->userenv->{branch};
            }
            push @branches_loop, {
                branchcode => $branch->{branchcode},
                branchname => $branch->{branchname},
                selected => $selected
            };
        }
    }

#if the basket is closed,and the user has the permission to edit basketgroups, display a list of basketgroups
    my ($basketgroup, $basketgroups);
    my $staffuser = GetMember(borrowernumber => $loggedinuser);
    if ($basket->{closedate} && haspermission($staffuser->{userid}, { acquisition => 'group_manage'} )) {
        $basketgroups = GetBasketgroups($basket->{booksellerid});
        for my $bg ( @{$basketgroups} ) {
            if ($basket->{basketgroupid} && $basket->{basketgroupid} == $bg->{id}){
                $bg->{default} = 1;
                $basketgroup = $bg;
            }
        }
    }

    # if the basket is closed, calculate estimated delivery date
    my $estimateddeliverydate;
    if( $basket->{closedate} ) {
        my ($year, $month, $day) = ($basket->{closedate} =~ /(\d+)-(\d+)-(\d+)/);
        ($year, $month, $day) = Add_Delta_Days($year, $month, $day, $bookseller->{deliverytime});
        $estimateddeliverydate = sprintf( "%04d-%02d-%02d", $year, $month, $day );
    }

    # if new basket, pre-fill infos
    $basket->{creationdate} = ""            unless ( $basket->{creationdate} );
    $basket->{authorisedby} = $loggedinuser unless ( $basket->{authorisedby} );
    $debug
      and warn sprintf
      "loggedinuser: $loggedinuser; creationdate: %s; authorisedby: %s",
      $basket->{creationdate}, $basket->{authorisedby};

    my @basketusers_ids = GetBasketUsers($basketno);
    my @basketusers;
    foreach my $basketuser_id (@basketusers_ids) {
        my $basketuser = GetMember(borrowernumber => $basketuser_id);
        push @basketusers, $basketuser if $basketuser;
    }

    my $active_currency = Koha::Acquisition::Currencies->get_active;

    my @orders = GetOrders( $basketno );
    my @books_loop;

    my @book_foot_loop;
    my %foot;
    my $total_quantity = 0;
    my $total_gste = 0;
    my $total_gsti = 0;
    my $total_gstvalue = 0;
    for my $order (@orders) {
        $order = C4::Acquisition::populate_order_with_prices({ order => $order, booksellerid => $booksellerid, ordering => 1 });
        my $line = get_order_infos( $order, $bookseller);
        if ( $line->{uncertainprice} ) {
            $template->param( uncertainprices => 1 );
        }

        push @books_loop, $line;

        $foot{$$line{gstrate}}{gstrate} = $$line{gstrate};
        $foot{$$line{gstrate}}{gstvalue} += $$line{gstvalue};
        $total_gstvalue += $$line{gstvalue};
        $foot{$$line{gstrate}}{quantity}  += $$line{quantity};
        $total_quantity += $$line{quantity};
        $foot{$$line{gstrate}}{totalgste} += $$line{totalgste};
        $total_gste += $$line{totalgste};
        $foot{$$line{gstrate}}{totalgsti} += $$line{totalgsti};
        $total_gsti += $$line{totalgsti};
    }

    push @book_foot_loop, map {$_} values %foot;

    # Get cancelled orders
    my @cancelledorders = GetOrders($basketno, { cancelled => 1 });
    my @cancelledorders_loop;
    for my $order (@cancelledorders) {
        $order = C4::Acquisition::populate_order_with_prices({ order => $order, booksellerid => $booksellerid, ordering => 1 });
        my $line = get_order_infos( $order, $bookseller);
        push @cancelledorders_loop, $line;
    }

    my $contract = GetContract({
        contractnumber => $basket->{contractnumber}
    });

    if ($basket->{basketgroupid}){
        $basketgroup = GetBasketgroup($basket->{basketgroupid});
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

    $template->param(
        basketno             => $basketno,
        basket               => $basket,
        basketname           => $basket->{'basketname'},
        basketbranchcode     => $basket->{branch},
        basketnote           => $basket->{note},
        basketbooksellernote => $basket->{booksellernote},
        basketcontractno     => $basket->{contractnumber},
        basketcontractname   => $contract->{contractname},
        branches_loop        => \@branches_loop,
        creationdate         => $basket->{creationdate},
        authorisedby         => $basket->{authorisedby},
        authorisedbyname     => $basket->{authorisedbyname},
        users_ids            => join(':', @basketusers_ids),
        users                => \@basketusers,
        closedate            => $basket->{closedate},
        estimateddeliverydate=> $estimateddeliverydate,
        is_standing          => $basket->{is_standing},
        deliveryplace        => $basket->{deliveryplace},
        billingplace         => $basket->{billingplace},
        active               => $bookseller->{'active'},
        booksellerid         => $bookseller->{'id'},
        name                 => $bookseller->{'name'},
        books_loop           => \@books_loop,
        book_foot_loop       => \@book_foot_loop,
        cancelledorders_loop => \@cancelledorders_loop,
        total_quantity       => $total_quantity,
        total_gste           => sprintf( "%.2f", $total_gste ),
        total_gsti           => sprintf( "%.2f", $total_gsti ),
        total_gstvalue       => sprintf( "%.2f", $total_gstvalue ),
        currency             => $active_currency->currency,
        listincgst           => $bookseller->{listincgst},
        basketgroups         => $basketgroups,
        basketgroup          => $basketgroup,
        grouped              => $basket->{basketgroupid},
        # The double negatives and booleans here mean:
        # "A basket cannot be closed if there are no orders in it or it's a standing order basket."
        #
        # (The template has another implicit restriction that the order cannot be closed if there
        # are any orders with uncertain prices.)
        unclosable           => @orders ? $basket->{is_standing} : 1,
        has_budgets          => $has_budgets,
        duplinbatch          => $duplinbatch,
    );
}

$template->param( messages => \@messages );
output_html_with_http_headers $query, $cookie, $template->output;

sub get_order_infos {
    my $order = shift;
    my $bookseller = shift;
    my $qty = $order->{'quantity'} || 0;
    if ( !defined $order->{quantityreceived} ) {
        $order->{quantityreceived} = 0;
    }
    my $budget = GetBudget($order->{budget_id});
    my $basket = GetBasket($order->{basketno});

    my %line = %{ $order };
    # Don't show unreceived standing orders as received
    $line{order_received} = ( $qty == $order->{'quantityreceived'} && ( $basket->{is_standing} ? $qty : 1 ) );
    $line{basketno}       = $basketno;
    $line{budget_name}    = $budget->{budget_name};

    if ( $line{uncertainprice} ) {
        $line{rrpgste} .= ' (Uncertain)';
    }
    if ( $line{'title'} ) {
        my $volume      = $order->{'volume'};
        my $seriestitle = $order->{'seriestitle'};
        $line{'title'} .= " / $seriestitle" if $seriestitle;
        $line{'title'} .= " / $volume"      if $volume;
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

    foreach my $key (qw(transferred_from transferred_to)) {
        if ($line{$key}) {
            my $order = GetOrder($line{$key});
            my $bookseller = Koha::Acquisition::Bookseller->fetch({ id => $basket->{booksellerid} });
            $line{$key} = {
                order => $order,
                basket => $basket,
                bookseller => $bookseller,
                timestamp => $line{$key . '_timestamp'},
            };
        }
    }

    return \%line;
}

sub edi_close_and_order {
    my $confirm = $query->param('confirm') || $confirm_pref eq '2';
    if ($confirm) {
            my $edi_params = {
                basketno => $basketno,
                ean    => $ean,
            };
            if ( $basket->{branch} ) {
                $edi_params->{branchcode} = $basket->{branch};
            }
            if ( create_edi_order($edi_params) ) {
                #$template->param( edifile => 1 );
            }
        CloseBasket($basketno);

        # if requested, create basket group, close it and attach the basket
        if ( $query->param('createbasketgroup') ) {
            my $branchcode;
            if (    C4::Context->userenv
                and C4::Context->userenv->{'branch'}
                and C4::Context->userenv->{'branch'} ne "NO_LIBRARY_SET" )
            {
                $branchcode = C4::Context->userenv->{'branch'};
            }
            my $basketgroupid = NewBasketgroup(
                {
                    name          => $basket->{basketname},
                    booksellerid  => $booksellerid,
                    deliveryplace => $branchcode,
                    billingplace  => $branchcode,
                    closed        => 1,
                }
            );
            ModBasket(
                {
                    basketno      => $basketno,
                    basketgroupid => $basketgroupid
                }
            );
            print $query->redirect(
"/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=$booksellerid&closed=1"
            );
        }
        else {
            print $query->redirect(
                "/cgi-bin/koha/acqui/booksellers.pl?booksellerid=$booksellerid"
            );
        }
        exit;
    }
    else {
        $template->param(
            edi_confirm     => 1,
            booksellerid    => $booksellerid,
            basketno        => $basket->{basketno},
            basketname      => $basket->{basketname},
            basketgroupname => $basket->{basketname},
        );
        if ($ean) {
            $template->param( ean => $ean );
        }

    }
    return;
}
