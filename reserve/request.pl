#!/usr/bin/perl


#written 2/1/00 by chris@katipo.oc.nz
# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2011 Catalyst IT
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

=head1 request.pl

script to place reserves/requests

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use List::MoreUtils qw( uniq );
use Date::Calc qw( Date_to_Days );
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use C4::Reserves qw( RevertWaitingStatus AlterPriority ToggleLowestPriority ToggleSuspend CanBookBeReserved GetMaxPatronHoldsForRecord CanItemBeReserved IsAvailableForItemLevelRequest );
use C4::Items qw( get_hostitemnumbers_of );
use C4::Koha qw( getitemtypeimagelocation );
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use C4::Circulation qw( _GetCircControlBranch GetBranchItemRule );
use Koha::DateUtils qw( dt_from_string );
use C4::Search qw( enabled_staff_search_views );

use Koha::Biblios;
use Koha::Checkouts;
use Koha::Holds;
use Koha::CirculationRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Patron::Attribute::Types;
use Koha::Clubs;
use Koha::BackgroundJob::BatchCancelHold;

my $dbh = C4::Context->dbh;
my $input = CGI->new;
my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "reserve/request.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { reserveforothers => 'place_holds' },
    }
);

my $showallitems = $input->param('showallitems');
my $pickup = $input->param('pickup');

my $itemtypes = {
    map {
        $_->itemtype =>
          { %{ $_->unblessed }, image_location => $_->image_location('intranet'), notforloan => $_->notforloan }
    } Koha::ItemTypes->search_with_localization->as_list
};

# Select borrowers infos
my $findborrower = $input->param('findborrower');
$findborrower = '' unless defined $findborrower;
$findborrower =~ s|,| |g;
my $findclub = $input->param('findclub');
$findclub = '' unless defined $findclub && !$findborrower;
my $borrowernumber_hold = $input->param('borrowernumber') || '';
my $club_hold = $input->param('club')||'';
my $messageborrower;
my $messageclub;
my $warnings;
my $messages;
my $exceeded_maxreserves;
my $exceeded_holds_per_record;

my $action = $input->param('action');
$action ||= q{};

if ( $action eq 'move' ) {
    my $where           = $input->param('where');
    my $reserve_id      = $input->param('reserve_id');
    my $prev_priority   = $input->param('prev_priority');
    my $next_priority   = $input->param('next_priority');
    my $first_priority  = $input->param('first_priority');
    my $last_priority   = $input->param('last_priority');
    my $hold_itemnumber = $input->param('itemnumber');
    if ( $prev_priority == 0 && $next_priority == 1 ) {
        C4::Reserves::RevertWaitingStatus( { itemnumber => $hold_itemnumber } );
    }
    else {
        AlterPriority(
            $where,         $reserve_id,     $prev_priority,
            $next_priority, $first_priority, $last_priority
        );
    }
}
elsif ( $action eq 'cancel' ) {
    my $reserve_id          = $input->param('reserve_id');
    my $cancellation_reason = $input->param("cancellation-reason");
    my $hold                = Koha::Holds->find($reserve_id);
    $hold->cancel( { cancellation_reason => $cancellation_reason } ) if $hold;
}
elsif ( $action eq 'setLowestPriority' ) {
    my $reserve_id = $input->param('reserve_id');
    ToggleLowestPriority($reserve_id);
}
elsif ( $action eq 'toggleSuspend' ) {
    my $reserve_id    = $input->param('reserve_id');
    my $suspend_until = $input->param('suspend_until');
    ToggleSuspend( $reserve_id, $suspend_until );
}
elsif ( $action eq 'cancelBulk' ) {
    my $cancellation_reason = $input->param("cancellation-reason");
    my @hold_ids            = split( ',', scalar $input->param("ids"));
    my $params              = {
        reason   => $cancellation_reason,
        hold_ids => \@hold_ids,
    };
    my $job_id = Koha::BackgroundJob::BatchCancelHold->new->enqueue($params);

    $template->param(
        enqueued => 1,
        job_id   => $job_id
    );
}

if ($findborrower) {
    my $patron = Koha::Patrons->find( { cardnumber => $findborrower } );
    $borrowernumber_hold = $patron->borrowernumber if $patron;
}

if($findclub) {
    my $club = Koha::Clubs->find( { name => $findclub } );
    if( $club ) {
        $club_hold = $club->id;
    } else {
        my @clubs = Koha::Clubs->search( [
            { name => { like => '%'.$findclub.'%' } },
            { description => { like => '%'.$findclub.'%' } }
        ] )->as_list;
        if( scalar @clubs == 1 ) {
            $club_hold = $clubs[0]->id;
        } elsif ( @clubs ) {
            $template->param( clubs => \@clubs );
        } else {
            $messageclub = "'$findclub'";
        }
    }
}

my @biblionumbers = $input->multi_param('biblionumber');

my $multi_hold = @biblionumbers > 1;
$template->param(
    multi_hold => $multi_hold,
);

# If we have the borrowernumber because we've performed an action, then we
# don't want to try to place another reserve.
if ($borrowernumber_hold && !$action) {
    my $patron = Koha::Patrons->find( $borrowernumber_hold );
    my $diffbranch;

    # we check the reserves of the user, and if they can reserve a document
    # FIXME At this time we have a simple count of reservs, but, later, we could improve the infos "title" ...

    my $reserves_count = $patron->holds->count;

    my $new_reserves_count = scalar( @biblionumbers );

    my $maxreserves = C4::Context->preference('maxreserves');
    $template->param( maxreserves => $maxreserves );

    if ( $maxreserves
        && ( $reserves_count + $new_reserves_count > $maxreserves ) )
    {
        my $new_reserves_allowed =
            $maxreserves - $reserves_count > 0
          ? $maxreserves - $reserves_count
          : 0;
        $warnings             = 1;
        $exceeded_maxreserves = 1;
        $template->param(
            new_reserves_allowed => $new_reserves_allowed,
            new_reserves_count   => $new_reserves_count,
            reserves_count       => $reserves_count,
            maxreserves          => $maxreserves,
        );
    }

    # check if the borrower make the reserv in a different branch
    if ( $patron->branchcode ne C4::Context->userenv->{'branch'} ) {
        $diffbranch = 1;
    }

    my $amount_outstanding = $patron->account->balance;
    $template->param(
                patron              => $patron,
                diffbranch          => $diffbranch,
                messages            => $messages,
                warnings            => $warnings,
                amount_outstanding  => $amount_outstanding,
    );
}

if ($club_hold && !$borrowernumber_hold && !$action) {
    my $club = Koha::Clubs->find($club_hold);

    my $enrollments = $club->club_enrollments;

    my $maxreserves = C4::Context->preference('maxreserves');
    my $new_reserves_count = scalar( @biblionumbers );

    my @members;

    while(my $enrollment = $enrollments->next) {
        next if $enrollment->is_canceled;
        my $member = { patron => $enrollment->patron };
        my $reserves_count = $enrollment->patron->holds->count;
        if ( $maxreserves
            && ( $reserves_count + $new_reserves_count > $maxreserves ) )
        {
            $member->{new_reserves_allowed} = $maxreserves - $reserves_count > 0
                ? $maxreserves - $reserves_count
                : 0;
            $member->{exceeded_maxreserves} = 1;
        }
        $member->{amount_outstanding} = $enrollment->patron->account->balance;
        if ( $enrollment->patron->branchcode ne C4::Context->userenv->{'branch'} ) {
            $member->{diffbranch} = 1;
        }

        push @members, $member;
    }

    $template->param(
        club                => $club,
        members             => \@members,
        maxreserves         => $maxreserves,
        new_reserves_count  => $new_reserves_count
    );
}

unless ( $club_hold or $borrowernumber_hold ) {
    $template->param( clubcount => Koha::Clubs->search->count );
}

$template->param(
    messageborrower => $messageborrower,
    messageclub     => $messageclub
);

# Load the hold list if
#  - we are searching for a patron or club and found one
#  - we are not searching for anything
if (   ( $findborrower && $borrowernumber_hold || $findclub && $club_hold )
    || ( !$findborrower && !$findclub ) )
{
    # FIXME launch another time GetMember perhaps until (Joubu: Why?)
    my $patron = Koha::Patrons->find( $borrowernumber_hold );

    if ( $patron && $multi_hold ) {
        my @multi_pickup_locations =
          Koha::Biblios->search( { biblionumber => \@biblionumbers } )
          ->pickup_locations( { patron => $patron } )->as_list;
        $template->param( multi_pickup_locations => \@multi_pickup_locations );
    }

    my $logged_in_patron = Koha::Patrons->find( $borrowernumber );

    my $wants_check;
    if ($patron) {
        $wants_check = $patron->wants_check_for_previous_checkout;
    }
    my $itemdata_enumchron = 0;
    my $itemdata_ccode = 0;
    my @biblioloop = ();
    my $no_reserves_allowed = 0;
    my $num_bibs_available = 0;
    foreach my $biblionumber (@biblionumbers) {
        next unless $biblionumber =~ m|^\d+$|;

        my %biblioloopiter = ();

        my $biblio = Koha::Biblios->find( $biblionumber );

        unless ($biblio) {
            $biblioloopiter{noitems} = 1;
            $template->param('nobiblio' => 1);
            last;
        }

        $biblioloopiter{object} = $biblio;

        if ( $patron ) {
            { # CanBookBeReserved
                my $canReserve = CanBookBeReserved( $patron->borrowernumber, $biblionumber );
                if ( $canReserve->{status} eq 'OK' ) {

                    #All is OK and we can continue
                }
                elsif ( $canReserve->{status} eq 'noReservesAllowed' || $canReserve->{status} eq 'notReservable' ) {
                    $no_reserves_allowed = 1;
                }
                elsif ( $canReserve->{status} eq 'tooManyReserves' ) {
                    $exceeded_maxreserves = 1;
                    $template->param( maxreserves => $canReserve->{limit} );
                }
                elsif ( $canReserve->{status} eq 'tooManyHoldsForThisRecord' ) {
                    $exceeded_holds_per_record = 1;
                    $biblioloopiter{ $canReserve->{status} } = 1;
                }
                elsif ( $canReserve->{status} eq 'ageRestricted' ) {
                    $template->param( $canReserve->{status} => 1 );
                    $biblioloopiter{ $canReserve->{status} } = 1;
                }
                elsif ( $canReserve->{status} eq 'alreadypossession' ) {
                    $template->param( $canReserve->{status} => 1);
                    $biblioloopiter{ $canReserve->{status} } = 1;
                }
                elsif ( $canReserve->{status} eq 'recall' ) {
                    $template->param( $canReserve->{status} => 1 );
                    $biblioloopiter{ $canReserve->{status} } = 1;
                }
                else {
                    $biblioloopiter{ $canReserve->{status} } = 1;
                }
            }

            # For multiple holds per record, if a patron has previously placed a hold,
            # the patron can only place more holds of the same type. That is, if the
            # patron placed a record level hold, all the holds the patron places must
            # be record level. If the patron placed an item level hold, all holds
            # the patron places must be item level
            my $holds = Koha::Holds->search(
                {
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $biblionumber,
                    found          => undef,
                }
            );
            $template->param( force_hold_level => $holds->forced_hold_level() );

            # For a librarian to be able to place multiple record holds for a patron for a record,
            # we must find out what the maximum number of holds they can place for the patron is
            my $max_holds_for_record = GetMaxPatronHoldsForRecord( $patron->borrowernumber, $biblionumber );
            my $remaining_holds_for_record = $max_holds_for_record - $holds->count();
            $biblioloopiter{remaining_holds_for_record} = $max_holds_for_record;
            $template->param( max_holds_for_record => $max_holds_for_record );
            $template->param( remaining_holds_for_record => $remaining_holds_for_record );
        }

        # adding a fixed value for priority options
        my $fixedRank = $biblio->holds->count + 1;

        my @items = $biblio->items->as_list;

        my @host_items = $biblio->host_items->as_list;
        if (@host_items) {
            push @items, @host_items;
        }

        unless ( @items ) {
            # FIXME Then why do we continue?
            $template->param('noitems' => 1) unless ( $multi_hold );
            $biblioloopiter{noitems} = 1;
        }

        if ( $club_hold or $borrowernumber_hold ) {
            my @available_itemtypes;
            my $num_items_available = 0;
            my $num_override  = 0;
            my $hiddencount   = 0;
            my $num_alreadyheld = 0;

            # iterating through all items first to check if any of them available
            # to pass this value further inside down to IsAvailableForItemLevelRequest to
            # it's complicated logic to analyse.
            # (before this loop was inside that sub loop so it was O(n^2) )

            for my $item_object ( @items ) {
                my $do_check;
                my $item = $item_object->unblessed;
                $item->{object} = $item_object;
                if ( $patron ) {
                    $do_check = $patron->do_check_for_previous_checkout($item) if $wants_check;
                    if ( $do_check && $wants_check ) {
                        $item->{checked_previously} = $do_check;
                        if ( $multi_hold ) {
                            $biblioloopiter{checked_previously} = $do_check;
                        } else {
                            $template->param( checked_previously => $do_check );
                        }
                    }
                }

                $item->{itemtype} = $itemtypes->{ $item_object->effective_itemtype };

                if($item->{biblionumber} ne $biblio->biblionumber){
                    $item->{hosttitle} = Koha::Biblios->find( $item->{biblionumber} )->title;
                }

                # if the item is currently on loan, we display its return date and
                # change the background color
                my $issue = $item_object->checkout;
                if ( $issue ) { # FIXME must be moved to the template
                    $item->{date_due} = $issue->date_due;
                    $item->{backgroundcolor} = 'onloan';
                }

                # checking reserve
                my $holds = $item_object->current_holds;
                if ( my $first_hold = $holds->next ) {
                    my $p = Koha::Patrons->find( $first_hold->borrowernumber );

                    $item->{backgroundcolor} = 'reserved';
                    $item->{reservedate}     = $first_hold->reservedate;
                    $item->{ReservedFor}     = $p;
                    $item->{ExpectedAtLibrary}     = $first_hold->branchcode;
                    $item->{waitingdate} = $first_hold->waitingdate;
                }

                # Management of the notforloan document
                if ( $item->{notforloan} ) {
                    $item->{backgroundcolor} = 'other';
                }

                # Management of lost or long overdue items
                if ( $item->{itemlost} ) {
                    $item->{backgroundcolor} = 'other';
                    if ($logged_in_patron->category->hidelostitems && !$showallitems) {
                        $item->{hide} = 1;
                        $hiddencount++;
                    }
                }

                # Check the transit status
                my $transfer = $item_object->get_transfer;
                if ( $transfer && $transfer->in_transit ) {
                    $item->{transfertwhen} = $transfer->datesent;
                    $item->{transfertfrom} = $transfer->frombranch;
                    $item->{transfertto} = $transfer->tobranch;
                    $item->{nocancel} = 1;
                }

                # If there is no loan, return and transfer, we show a checkbox.
                $item->{notforloanitype} = $item->{itemtype}->{notforloan};
                $item->{notforloan} ||= 0;

                # if independent branches is on we need to check if the person can reserve
                # for branches they arent logged in to
                if ( C4::Context->preference("IndependentBranches") ) {
                    if (! C4::Context->preference("canreservefromotherbranches")){
                        # can't reserve items so need to check if item homebranch and userenv branch match if not we can't reserve
                        my $userenv = C4::Context->userenv;
                        unless ( C4::Context->IsSuperLibrarian ) {
                            $item->{cantreserve} = 1 if ( $item->{homebranch} ne $userenv->{branch} );
                        }
                    }
                }

                if ( $patron ) {
                    my $patron_unblessed = $patron->unblessed;
                    my $branch = C4::Circulation::_GetCircControlBranch($item, $patron_unblessed);

                    my $branchitemrule = GetBranchItemRule( $branch, $item->{'itype'} );

                    $item->{'holdallowed'} = $branchitemrule->{'holdallowed'};

                    my $can_item_be_reserved = CanItemBeReserved( $patron, $item_object, undef, { get_from_cache => 1 } )->{status};
                    $item->{not_holdable} = $can_item_be_reserved unless ( $can_item_be_reserved eq 'OK' );
                    $item->{not_holdable} ||= 'notforloan' if ( $item->{notforloanitype} || $item->{notforloan} > 0 );


                    $item->{item_level_holds} = Koha::CirculationRules->get_opacitemholds_policy( { item => $item_object, patron => $patron } );

                    my $default_hold_pickup_location_pref = C4::Context->preference('DefaultHoldPickupLocation');
                    my $default_pickup_branch;
                    if( $default_hold_pickup_location_pref eq 'homebranch' ){
                        $default_pickup_branch = $item->{homebranch};
                    } elsif ( $default_hold_pickup_location_pref eq 'holdingbranch' ){
                        $default_pickup_branch = $item->{holdingbranch};
                    } else {
                        $default_pickup_branch = C4::Context->userenv->{branch};
                    }

                    if ( $can_item_be_reserved eq 'itemAlreadyOnHold' ) {
                        # itemAlreadyOnHold cannot be overridden
                        $num_alreadyheld++
                    }
                    elsif (
                        (
                               !$item->{cantreserve}
                            && !$exceeded_maxreserves
                            && $can_item_be_reserved eq 'OK'
                            && IsAvailableForItemLevelRequest($item_object, $patron, undef)
                        ) || C4::Context->preference('AllowHoldPolicyOverride')
                             # If AllowHoldPolicyOverride is set, it overrides EVERY restriction
                             # not just branch item rules
                      )
                    {
                        # Send the pickup locations count to the UI, the pickup locations will be pulled using the API
                        my $pickup_locations = $item_object->pickup_locations({ patron => $patron });
                        $item->{pickup_locations_count} = $pickup_locations->count;
                        if ( $item->{pickup_locations_count} > 0 ) {
                            $num_items_available++;
                            $item->{available} = 1;
                            # pass the holding branch for use as default
                            my $default_pickup_location = $pickup_locations->search({ branchcode => $default_pickup_branch })->next;
                            $item->{default_pickup_location} = $default_pickup_location;
                        }
                        elsif ( C4::Context->preference('AllowHoldPolicyOverride') ){
                             $num_items_available++;
                             $item->{override} = 1;
                            my $default_pickup_location = $pickup_locations->search({ branchcode => $default_pickup_branch })->next;
                            $item->{default_pickup_location} = $default_pickup_location;
                        }
                        else {
                            $item->{available} = 0;
                            $item->{not_holdable} = "no_valid_pickup_location";
                        }

                        push( @available_itemtypes, $item->{itype} );
                    } else {
                        # If none of the conditions hold true, then neither override nor available is set and the item cannot be checked
                        $item->{available} = 0;
                    }


                    # Show serial enumeration when needed
                    if ($item->{enumchron}) {
                        $itemdata_enumchron = 1;
                    }
                    # Show collection when needed
                    if ($item->{ccode}) {
                        $itemdata_ccode = 1;
                    }
                }

                push @{ $biblioloopiter{itemloop} }, $item;
            }

            $biblioloopiter{biblioitem} = $biblio->biblioitem;

            # While we can't override an alreay held item, we should be able to override the others
            # Unless all items are already held
            if ( $num_override > 0 && ($num_override + $num_alreadyheld) == scalar( @{ $biblioloopiter{itemloop} } ) ) {
            # That is, if all items require an override
                $template->param( override_required => 1 );
            } elsif ( $num_items_available == 0 ) {
                $template->param( none_available => 1 );
                $biblioloopiter{warn} = 1;
                $biblioloopiter{none_avail} = 1;
            }
            $template->param( hiddencount => $hiddencount);

            @available_itemtypes = uniq( @available_itemtypes );
            $template->param( available_itemtypes => \@available_itemtypes );
        }

        # existingreserves building
        my @reserveloop;
        my $always_show_holds = $input->cookie('always_show_holds');
        $template->param( always_show_holds => $always_show_holds );
        my $show_holds_now = $input->param('show_holds_now');
        unless( (defined $always_show_holds && $always_show_holds eq 'DONT') && !$show_holds_now ){
            my @reserves = Koha::Holds->search( { biblionumber => $biblionumber }, { order_by => 'priority' } )->as_list;
            foreach my $res (
                sort {
                    my $a_found = $a->found() || '';
                    my $b_found = $a->found() || '';
                    $a_found cmp $b_found;
                } @reserves
              )
            {
                my %reserve;
                if ( $res->is_found() ) {
                    $reserve{'holdingbranch'} = $res->item()->holdingbranch();
                    $reserve{'biblionumber'}  = $res->item()->biblionumber();
                    $reserve{'barcodenumber'} = $res->item()->barcode();
                    $reserve{'wbrcode'}       = $res->branchcode();
                    $reserve{'itemnumber'}    = $res->itemnumber();
                    $reserve{'wbrname'}       = $res->branch()->branchname();
                    $reserve{'atdestination'} = $res->is_at_destination();
                    $reserve{'desk_name'}     = ( $res->desk() ) ? $res->desk()->desk_name() : '' ;
                    $reserve{'found'}     = $res->is_found();
                    $reserve{'inprocessing'} = $res->is_in_processing();
                    $reserve{'intransit'} = $res->is_in_transit();
                }
                elsif ( $res->priority() > 0 ) {
                    if ( my $item = $res->item() )  {
                        $reserve{'itemnumber'}      = $item->id();
                        $reserve{'barcodenumber'}   = $item->barcode();
                        $reserve{'item_level_hold'} = 1;
                    }
                }

                $reserve{'expirationdate'} = $res->expirationdate;
                $reserve{'date'}           = $res->reservedate;
                $reserve{'borrowernumber'} = $res->borrowernumber();
                $reserve{'biblionumber'}   = $res->biblionumber();
                $reserve{'patron'}         = $res->borrower;
                $reserve{'notes'}          = $res->reservenotes();
                $reserve{'waiting_date'}   = $res->waitingdate();
                $reserve{'ccode'}          = $res->item() ? $res->item()->ccode() : undef;
                $reserve{'barcode'}        = $res->item() ? $res->item()->barcode() : undef;
                $reserve{'priority'}       = $res->priority();
                $reserve{'lowestPriority'} = $res->lowestPriority();
                $reserve{'suspend'}        = $res->suspend();
                $reserve{'suspend_until'}  = $res->suspend_until();
                $reserve{'reserve_id'}     = $res->reserve_id();
                $reserve{itemtype}         = $res->itemtype();
                $reserve{branchcode}       = $res->branchcode();
                $reserve{non_priority}     = $res->non_priority();
                $reserve{object}           = $res;

                push( @reserveloop, \%reserve );
            }
        }

        # get the time for the form name...
        my $time = time();

        $template->param(
                         time        => $time,
                         fixedRank   => $fixedRank,
                        );

        # display infos
        $template->param(
                         itemdata_enumchron => $itemdata_enumchron,
                         itemdata_ccode    => $itemdata_ccode,
                         date              => dt_from_string,
                         biblionumber      => $biblionumber,
                         findborrower      => $findborrower,
                         biblio            => $biblio,
                         holdsview         => 1,
                         C4::Search::enabled_staff_search_views,
                        );

        $biblioloopiter{biblionumber} = $biblionumber;
        $biblioloopiter{title}  = $biblio->title;
        $biblioloopiter{author} = $biblio->author;
        $biblioloopiter{rank} = $fixedRank;
        $biblioloopiter{reserveloop} = \@reserveloop;

        if (@reserveloop) {
            $template->param( reserveloop => \@reserveloop );
        }

        if ( $patron && $multi_hold ) {
            # Add the valid pickup locations
            my @pickup_locations = $biblio->pickup_locations({ patron => $patron })->as_list;
            $biblioloopiter{pickup_locations} = \@pickup_locations;
            $biblioloopiter{pickup_locations_codes} = [ map { $_->branchcode } @pickup_locations ];
        }

        $num_bibs_available++ unless $biblioloopiter{none_avail};
        push @biblioloop, \%biblioloopiter;
    }

    $template->param( no_bibs_available => 1 ) unless $num_bibs_available > 0;

    $template->param( biblioloop => \@biblioloop );
    $template->param( no_reserves_allowed => $no_reserves_allowed );
    $template->param( exceeded_maxreserves => $exceeded_maxreserves );
    $template->param( exceeded_holds_per_record => $exceeded_holds_per_record );
    # FIXME: getting just the first bib's result doesn't seem right
    $template->param( subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumbers[0]));
} elsif ( ! $multi_hold ) {
    my $biblio = Koha::Biblios->find( $biblionumbers[0] );
    $template->param( biblio => $biblio );
}
$template->param( biblionumbers => \@biblionumbers );

$template->param(
    attribute_type_codes => ( C4::Context->preference('ExtendedPatronAttributes')
        ? [ Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->get_column('code') ]
        : []
    ),
);


# pass the userenv branch if no pickup location selected
$template->param( pickup => $pickup || C4::Context->userenv->{branch} );

$template->param(borrowernumber => $borrowernumber_hold);

# printout the page
output_html_with_http_headers $input, $cookie, $template->output;

sub sort_borrowerlist {
    my $borrowerslist = shift;
    my $ref           = [];
    push @{$ref}, sort {
        uc( $a->{surname} . $a->{firstname} ) cmp
          uc( $b->{surname} . $b->{firstname} )
    } @{$borrowerslist};
    return $ref;
}
