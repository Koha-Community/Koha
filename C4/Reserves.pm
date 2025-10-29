package C4::Reserves;

# Copyright 2000-2002 Katipo Communications
#           2006 SAN Ouest Provence
#           2007-2010 BibLibre Paul POULAIN
#           2011 Catalyst IT
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

use JSON qw( to_json );

use C4::Accounts;
use C4::Biblio      qw( GetMarcFromKohaField );
use C4::Circulation qw( CheckIfIssuedToPatron GetAgeRestriction GetBranchItemRule );
use C4::Context;
use C4::Items qw( CartToShelf get_hostitemnumbers_of );
use C4::Letters;
use C4::Log qw( logaction );
use C4::Members::Messaging;
use C4::Members;
use Koha::Account::Lines;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Biblios;
use Koha::Calendar;
use Koha::Cache::Memory::Lite;
use Koha::CirculationRules;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Holds;
use Koha::ItemTypes;
use Koha::Items;
use Koha::Libraries;
use Koha::Library;
use Koha::Patrons;
use Koha::Plugins;
use Koha::Policy::Holds;

use List::MoreUtils qw( any );

=head1 NAME

C4::Reserves - Koha functions for dealing with reservation.

=head1 SYNOPSIS

  use C4::Reserves;

=head1 DESCRIPTION

This modules provides some functions to deal with reservations.

  Reserves are stored in reserves table.
  The following columns contains important values :
  - priority >0      : then the reserve is at 1st stage, and not yet affected to any item.
             =0      : then the reserve is being dealt
  - found : NULL         : means the patron requested the 1st available, and we haven't chosen the item
            T(ransit)    : the reserve is linked to an item but is in transit to the pickup branch
            W(aiting)    : the reserve is linked to an item, is at the pickup branch, and is waiting on the hold shelf
            F(inished)   : the reserve has been completed, and is done
            P(rocessing) : reserved item has been returned using self-check machine and reserve needs to be confirmed
                           by librarian before notice is send and status changed to waiting.
                           Applicable only if HoldsNeedProcessingSIP system preference is set.
  - itemnumber : empty : the reserve is still unaffected to an item
                 filled: the reserve is attached to an item
  The complete workflow is :
  ==== 1st use case ====
  patron request a document, 1st available :                      P >0, F=NULL, I=NULL
  a library having it run "transfertodo", and clic on the list
         if there is no transfer to do, the reserve waiting
         patron can pick it up                                    P =0, F=W,    I=filled
         if there is a transfer to do, write in branchtransfer    P =0, F=T,    I=filled
           The pickup library receive the book, it check in       P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled

  ==== 2nd use case ====
  patron requests a document, a given item,
    If pickup is holding branch                                   P =0, F=W,   I=filled
    If transfer needed, write in branchtransfer                   P =0, F=T,    I=filled
        The pickup library receive the book, it checks it in      P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled

=head1 FUNCTIONS

=cut

our ( @ISA, @EXPORT_OK );

BEGIN {
    require Exporter;
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(
        AddReserve

        GetReserveStatus

        ChargeReserveFee
        GetReserveFee

        ModReserveAffect
        ModReserve
        ModReserveStatus
        ModReserveCancelAll
        ModReserveMinusPriority
        MoveReserve

        CheckReserves
        CanBookBeReserved
        CanItemBeReserved
        CancelExpiredReserves

        AutoUnsuspendReserves

        IsAvailableForItemLevelRequest
        ItemsAnyAvailableAndNotRestricted

        AlterPriority
        ToggleLowestPriority

        ReserveSlip
        SuspendAll

        CalculatePriority

        GetMaxPatronHoldsForRecord

        MergeHolds
    );
}

=head2 AddReserve

    AddReserve(
        {
            branchcode       => $branchcode,
            borrowernumber   => $borrowernumber,
            biblionumber     => $biblionumber,
            priority         => $priority,
            reservation_date => $reservation_date,
            expiration_date  => $expiration_date,
            notes            => $notes,
            title            => $title,
            itemnumber       => $itemnumber,
            found            => $found,
            itemtype         => $itemtype,
            item_group_id    => $item_group_id
        }
    );

Adds reserve and generates HOLDPLACED message and HOLDPLACED_PATRON message.

The following tables are available within the HOLDPLACED message:

    branches
    borrowers
    biblio
    biblioitems
    items
    reserves

The following tables are available within the HOLDPLACED_PATRON message:

    borrowers
    reserves

=cut

sub AddReserve {
    my ($params)               = @_;
    my $branch                 = $params->{branchcode};
    my $borrowernumber         = $params->{borrowernumber};
    my $biblionumber           = $params->{biblionumber};
    my $priority               = $params->{priority};
    my $resdate                = $params->{reservation_date};
    my $patron_expiration_date = $params->{expiration_date};
    my $notes                  = $params->{notes};
    my $title                  = $params->{title};
    my $checkitem              = $params->{itemnumber};
    my $found                  = $params->{found};
    my $itemtype               = $params->{itemtype};
    my $non_priority           = $params->{non_priority};
    my $item_group_id          = $params->{item_group_id};
    my $confirmations          = $params->{confirmations};
    my $forced                 = $params->{forced};

    $resdate ||= dt_from_string;

    # if we have an item selectionned, and the pickup branch is the same as the holdingbranch
    # of the document, we force the value $priority and $found .
    if ( $checkitem and not C4::Context->preference('ReservesNeedReturns') ) {
        my $item = Koha::Items->find($checkitem);    # FIXME Prevent bad calls

        if (
            # If item is already checked out, it cannot be set waiting
            !$item->onloan

            # The item can't be waiting if it needs a transfer
            && $item->holdingbranch eq $branch

            # Similarly, if in transit it can't be waiting
            && !$item->get_transfer

            # If we can't hold damaged items, and it is damaged, it can't be waiting
            && ( $item->damaged && C4::Context->preference('AllowHoldsOnDamagedItems') || !$item->damaged )

            # Lastly, if this already has holds, we shouldn't make it waiting for the new hold
            && !$item->current_holds->count
            )
        {
            $priority = 0;
            $found    = 'W';
        }
    }
    if ( C4::Context->preference('AllowHoldDateInFuture') ) {

        # Make room in reserves for this if passed a priority
        $priority = _ShiftPriority( $biblionumber, $priority );
    }

    my $waitingdate;

    # If the reserve had the waiting status, we had the value of the resdate
    if ( $found && $found eq 'W' ) {
        $waitingdate = $resdate;
    }

    # Don't add itemtype limit if specific item is selected
    $itemtype = undef if $checkitem;

    # updates take place here
    my $hold = Koha::Hold->new(
        {
            borrowernumber         => $borrowernumber,
            biblionumber           => $biblionumber,
            item_group_id          => $item_group_id,
            reservedate            => $resdate,
            branchcode             => $branch,
            priority               => $priority,
            reservenotes           => $notes,
            itemnumber             => $checkitem,
            found                  => $found,
            waitingdate            => $waitingdate,
            patron_expiration_date => $patron_expiration_date,
            itemtype               => $itemtype,
            item_level_hold        => $checkitem    ? 1 : 0,
            non_priority           => $non_priority ? 1 : 0,
        }
    )->store();
    $hold->set_waiting() if $found && $found eq 'W';

    # record patron activity
    $hold->patron->update_lastseen('hold');

    # Log the hold creation
    if ( C4::Context->preference('HoldsLog') ) {
        my $info = $hold->id;
        if ( defined($confirmations) || defined($forced) ) {
            $info = to_json(
                {
                    hold          => $hold->id,
                    branchcode    => $hold->branchcode,
                    biblionumber  => $hold->biblionumber,
                    itemnumber    => $hold->itemnumber,
                    confirmations => $confirmations,
                    forced        => $forced
                },
                { pretty => 1, canonical => 1 }
            );
        }
        logaction( 'HOLDS', 'CREATE', $hold->id, $info );
    }

    my $reserve_id = $hold->id();

    # add a reserve fee if needed
    if ( C4::Context->preference('HoldFeeMode') ne 'any_time_is_collected' ) {
        my $reserve_fee = GetReserveFee( $borrowernumber, $biblionumber );
        ChargeReserveFee( $borrowernumber, $reserve_fee, $title );
    }

    _FixPriority( { biblionumber => $biblionumber } );

    # Send e-mail to librarian if syspref is active
    if ( C4::Context->preference("emailLibrarianWhenHoldIsPlaced") ) {
        my $patron  = $hold->patron;
        my $library = $patron->library;
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'reserves',
                letter_code => 'HOLDPLACED',
                branchcode  => $branch,
                lang        => $patron->lang,
                tables      => {
                    'branches'    => $library->unblessed,
                    'borrowers'   => $patron->unblessed,
                    'biblio'      => $biblionumber,
                    'biblioitems' => $biblionumber,
                    'items'       => $checkitem,
                    'reserves'    => $hold->unblessed,
                },
            )
            )
        {

            my $branch_email_address = $library->inbound_email_address;

            C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $borrowernumber,
                    message_transport_type => 'email',
                    to_address             => $branch_email_address,
                }
            );
        }
    }

    # Send email to patron if syspref is active
    if ( C4::Context->preference("EmailPatronWhenHoldIsPlaced") ) {
        my $patron = $hold->patron;
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'reserves',
                letter_code => 'HOLDPLACED_PATRON',
                branchcode  => $branch,
                lang        => $patron->lang,
                tables      => {
                    borrowers => $patron->unblessed,
                    reserves  => $hold->unblessed,
                },
            )
            )
        {
            C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $borrowernumber,
                    message_transport_type => 'email',
                    to_address             => $patron->notice_email_address,
                }
            );
        }
    }

    Koha::Plugins->call( 'after_hold_create', $hold );
    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'place',
            payload => { hold => $hold->get_from_storage }
        }
    );

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [$biblionumber] } )
        if C4::Context->preference('RealTimeHoldsQueue');

    return $reserve_id;
}

=head2 CanBookBeReserved

  $canReserve = &CanBookBeReserved($borrowernumber, $biblionumber, $branchcode, $params)
  if ($canReserve eq 'OK') { #We can reserve this Item! }

  $params are passed directly through to CanItemBeReserved

See CanItemBeReserved() for possible return values.

=cut

sub CanBookBeReserved {
    my ( $borrowernumber, $biblionumber, $pickup_branchcode, $params ) = @_;

    # Check that patron have not checked out this biblio (if AllowHoldsOnPatronsPossessions set)
    if ( !C4::Context->preference('AllowHoldsOnPatronsPossessions')
        && C4::Circulation::CheckIfIssuedToPatron( $borrowernumber, $biblionumber ) )
    {
        return { status => 'alreadypossession' };
    }

    if ( $params->{itemtype} ) {

        # biblio-level, item type-contrained
        my $patron          = Koha::Patrons->find($borrowernumber);
        my $reservesallowed = Koha::CirculationRules->get_effective_rule(
            {
                itemtype     => $params->{itemtype},
                categorycode => $patron->categorycode,
                branchcode   => $pickup_branchcode,
                rule_name    => 'reservesallowed',
            }
        )->rule_value;

        $reservesallowed = ( $reservesallowed eq '' ) ? undef : $reservesallowed;

        my $count = $patron->holds->search(
            {
                '-or' => [
                    { 'me.itemtype' => $params->{itemtype} },
                    { 'item.itype'  => $params->{itemtype} }
                ]
            },
            { join => ['item'] }
        )->count;

        return { status => '' }
            if defined $reservesallowed and $reservesallowed < $count + 1;
    }

    my $items;

    #get items linked via host records
    my @hostitemnumbers = get_hostitemnumbers_of($biblionumber);
    if (@hostitemnumbers) {
        $items = Koha::Items->search(
            {
                -or => [
                    biblionumber => $biblionumber,
                    itemnumber   => { -in => @hostitemnumbers }
                ]
            }
        );
    } else {
        $items = Koha::Items->search( { biblionumber => $biblionumber } );
    }

    my $canReserve = { status => '' };
    my $patron     = Koha::Patrons->find($borrowernumber);
    while ( my $item = $items->next ) {
        $canReserve = CanItemBeReserved( $patron, $item, $pickup_branchcode, $params );
        return { status => 'OK' } if $canReserve->{status} eq 'OK';
    }
    return $canReserve;
}

=head2 CanItemBeReserved

  $canReserve = &CanItemBeReserved($patron, $item, $branchcode, $params)
  if ($canReserve->{status} eq 'OK') { #We can reserve this Item! }

  current params are:
  'ignore_hold_counts' - we use this routine to check if an item can fill a hold - on this case we
  should not check if there are too many holds as we only care about reservability

@RETURNS { status => OK },              if the Item can be reserved.
         { status => ageRestricted },   if the Item is age restricted for this borrower.
         { status => damaged },         if the Item is damaged.
         { status => cannotReserveFromOtherBranches }, if syspref 'canreservefromotherbranches' is OK.
         { status => branchNotInHoldGroup }, if borrower home library is not in hold group, and holds are only allowed from hold groups.
         { status => tooManyReserves, limit => $limit }, if the borrower has exceeded their maximum reserve amount.
         { status => notReservable },   if holds on this item are not allowed
         { status => libraryNotFound },   if given branchcode is not an existing library
         { status => libraryNotPickupLocation },   if given branchcode is not configured to be a pickup location
         { status => cannotBeTransferred }, if branch transfer limit applies on given item and branchcode
         { status => pickupNotInHoldGroup }, pickup location is not in hold group, and pickup locations are only allowed from hold groups.
         { status => recall }, if the borrower has already placed a recall on this item

=cut

our $CanItemBeReserved_cache_key;

sub _cache {
    my ($return) = @_;
    my $memory_cache = Koha::Cache::Memory::Lite->get_instance();
    $memory_cache->set_in_cache( $CanItemBeReserved_cache_key, $return );
    return $return;
}

sub CanItemBeReserved {
    my ( $patron, $item, $pickup_branchcode, $params ) = @_;

    my $memory_cache = Koha::Cache::Memory::Lite->get_instance();
    $CanItemBeReserved_cache_key = sprintf "Hold_CanItemBeReserved:%s:%s:%s", $patron->borrowernumber,
        $item->itemnumber, $pickup_branchcode || "";
    if ( $params->{get_from_cache} ) {
        my $cached = $memory_cache->get_from_cache($CanItemBeReserved_cache_key);
        return $cached if $cached;
    }

    my $dbh = C4::Context->dbh;
    my $ruleitemtype;           # itemtype of the matching issuing rule
    my $allowedreserves = 0;    # Total number of holds allowed across all records, default to none

    # We check item branch if IndependentBranches is ON
    # and canreservefromotherbranches is OFF
    if ( C4::Context->preference('IndependentBranches')
        and !C4::Context->preference('canreservefromotherbranches') )
    {
        if ( $item->homebranch ne $patron->branchcode ) {
            return _cache { status => 'cannotReserveFromOtherBranches' };
        }
    }

    # If an item is damaged and we don't allow holds on damaged items, we can stop right here
    return _cache { status => 'damaged' }
        if ( $item->damaged
        && !C4::Context->preference('AllowHoldsOnDamagedItems') );

    if ( GetMarcFromKohaField('biblioitems.agerestriction') ) {
        my $biblio = $item->biblio;

        # Check for the age restriction
        my $ageRestriction = C4::Circulation::GetAgeRestriction( $biblio->biblioitem->agerestriction );
        return _cache { status => 'ageRestricted' }
            if $ageRestriction && $patron->dateofbirth && $ageRestriction > $patron->get_age();
    }

    # Check that the patron doesn't have an item level hold on this item already
    return _cache { status => 'itemAlreadyOnHold' }
        if ( !$params->{ignore_hold_counts}
        && Koha::Holds->search( { borrowernumber => $patron->borrowernumber, itemnumber => $item->itemnumber } )
        ->count() );

    # Check that patron have not checked out this biblio (if AllowHoldsOnPatronsPossessions set)
    if ( !C4::Context->preference('AllowHoldsOnPatronsPossessions')
        && C4::Circulation::CheckIfIssuedToPatron( $patron->borrowernumber, $item->biblionumber ) )
    {
        return _cache { status => 'alreadypossession' };
    }

    # check if a recall exists on this item from this borrower
    return _cache { status => 'recall' }
        if $patron->recalls->filter_by_current->search( { item_id => $item->itemnumber } )->count;

    my $controlbranch = C4::Context->preference('ReservesControlBranch');

    my $reserves_control_branch;
    my $branchfield = "reserves.branchcode";

    if ( $controlbranch eq "ItemHomeLibrary" ) {
        $branchfield             = "items.homebranch";
        $reserves_control_branch = $item->homebranch;
    } elsif ( $controlbranch eq "PatronLibrary" ) {
        $branchfield             = "borrowers.branchcode";
        $reserves_control_branch = $patron->branchcode;
    }

    # we retrieve rights
    if (
        my $reservesallowed = Koha::CirculationRules->get_effective_rule(
            {
                itemtype     => $item->effective_itemtype,
                categorycode => $patron->categorycode,
                branchcode   => $reserves_control_branch,
                rule_name    => 'reservesallowed',
            }
        )
        )
    {
        $ruleitemtype    = $reservesallowed->itemtype;
        $allowedreserves = $reservesallowed->rule_value // 0;    #undefined is 0, blank is unlimited
    } else {
        $ruleitemtype = undef;
    }

    my $rights = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $reserves_control_branch,
            rules        => [ 'holds_per_record', 'holds_per_day' ]
        }
    );
    my $holds_per_record = $rights->{holds_per_record} // 1;
    my $holds_per_day    = $rights->{holds_per_day};

    if ( defined $holds_per_record && $holds_per_record ne '' ) {
        if ( $holds_per_record == 0 ) {
            return _cache { status => "noReservesAllowed" };
        }
        if ( !$params->{ignore_hold_counts} ) {
            my $search_params = {
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
            };
            my $holds = Koha::Holds->search($search_params);
            return _cache { status => "tooManyHoldsForThisRecord", limit => $holds_per_record }
                if $holds->count() >= $holds_per_record;
        }
    }

    if ( !$params->{ignore_hold_counts} && defined $holds_per_day && $holds_per_day ne '' ) {
        my $today_holds = Koha::Holds->search(
            {
                borrowernumber => $patron->borrowernumber,
                reservedate    => dt_from_string->date
            }
        );
        return _cache { status => 'tooManyReservesToday', limit => $holds_per_day }
            if $today_holds->count() >= $holds_per_day;
    }

    # we check if it's ok or not
    if ( defined $allowedreserves && $allowedreserves ne '' ) {
        if ( $allowedreserves == 0 ) {
            return _cache { status => 'noReservesAllowed' };
        }
        if ( !$params->{ignore_hold_counts} ) {

            # we retrieve count
            my $querycount = q{
                SELECT count(*) AS count
                  FROM reserves
             LEFT JOIN items USING (itemnumber)
             LEFT JOIN biblioitems ON (reserves.biblionumber=biblioitems.biblionumber)
             LEFT JOIN borrowers USING (borrowernumber)
                 WHERE borrowernumber = ?
            };
            $querycount .= "AND ( $branchfield = ? OR $branchfield IS NULL )";

            # If using item-level itypes, fall back to the record
            # level itemtype if the hold has no associated item
            if ( defined $ruleitemtype ) {
                if ( C4::Context->preference('item-level_itypes') ) {
                    $querycount .= q{
                        AND ( COALESCE( items.itype, biblioitems.itemtype ) = ?
                           OR reserves.itemtype = ? )
                    };
                } else {
                    $querycount .= q{
                        AND ( biblioitems.itemtype = ?
                           OR reserves.itemtype = ? )
                    };
                }
            }

            my $sthcount = $dbh->prepare($querycount);

            if ( defined $ruleitemtype ) {
                $sthcount->execute( $patron->borrowernumber, $reserves_control_branch, $ruleitemtype, $ruleitemtype );
            } else {
                $sthcount->execute( $patron->borrowernumber, $reserves_control_branch );
            }

            my $reservecount = "0";
            if ( my $rowcount = $sthcount->fetchrow_hashref() ) {
                $reservecount = $rowcount->{count};
            }

            return _cache { status => 'tooManyReserves', limit => $allowedreserves }
                if $reservecount >= $allowedreserves;
        }
    }

    # Now we need to check hold limits by patron category
    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $patron->categorycode,
            branchcode   => $reserves_control_branch,
            rule_name    => 'max_holds',
        }
    );
    if ( !$params->{ignore_hold_counts} && $rule && defined( $rule->rule_value ) && $rule->rule_value ne '' ) {
        my $total_holds_count = Koha::Holds->search( { borrowernumber => $patron->borrowernumber } )->count();

        return _cache { status => 'tooManyReserves', limit => $rule->rule_value }
            if $total_holds_count >= $rule->rule_value;
    }

    my $branchitemrule = C4::Circulation::GetBranchItemRule( $reserves_control_branch, $item->effective_itemtype );

    if ( $branchitemrule->{holdallowed} eq 'not_allowed' ) {
        return _cache { status => 'notReservable' };
    }

    if (   $branchitemrule->{holdallowed} eq 'from_home_library'
        && $patron->branchcode ne $item->homebranch )
    {
        return _cache { status => 'cannotReserveFromOtherBranches' };
    }

    my $item_library = Koha::Libraries->find( { branchcode => $item->homebranch } );
    if ( $branchitemrule->{holdallowed} eq 'from_local_hold_group' ) {
        if ( $patron->branchcode ne $item->homebranch
            && !$item_library->validate_hold_sibling( { branchcode => $patron->branchcode } ) )
        {
            return _cache { status => 'branchNotInHoldGroup' };
        }
    }

    if ($pickup_branchcode) {
        my $destination = Koha::Libraries->find(
            {
                branchcode => $pickup_branchcode,
            }
        );

        unless ($destination) {
            return _cache { status => 'libraryNotFound' };
        }
        unless ( $destination->pickup_location ) {
            return _cache { status => 'libraryNotPickupLocation' };
        }
        unless ( $item->can_be_transferred( { to => $destination } ) ) {
            return _cache { status => 'cannotBeTransferred' };
        }
        if ( $branchitemrule->{hold_fulfillment_policy} eq 'holdgroup'
            && !$item_library->validate_hold_sibling( { branchcode => $pickup_branchcode } ) )
        {
            return _cache { status => 'pickupNotInHoldGroup' };
        }
        if ( $branchitemrule->{hold_fulfillment_policy} eq 'patrongroup'
            && !Koha::Libraries->find( { branchcode => $patron->branchcode } )
            ->validate_hold_sibling( { branchcode => $pickup_branchcode } ) )
        {
            return _cache { status => 'pickupNotInHoldGroup' };
        }
    }

    return _cache { status => 'OK' };
}

=head2 ChargeReserveFee

    $fee = ChargeReserveFee( $borrowernumber, $fee, $title );

    Charge the fee for a reserve (if $fee > 0)

=cut

sub ChargeReserveFee {
    my ( $borrowernumber, $fee, $title ) = @_;
    return if !$fee || $fee == 0;    # the last test is needed to include 0.00
    Koha::Account->new( { patron_id => $borrowernumber } )->add_debit(
        {
            amount       => $fee,
            description  => $title,
            note         => undef,
            user_id      => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
            library_id   => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
            interface    => C4::Context->interface,
            invoice_type => undef,
            type         => 'RESERVE',
            item_id      => undef
        }
    );
}

=head2 GetReserveFee

    $fee = GetReserveFee( $borrowernumber, $biblionumber );

    Calculate the fee for a reserve (if applicable).

=cut

sub GetReserveFee {
    my ( $borrowernumber, $biblionumber ) = @_;
    my $borquery = qq{
SELECT reservefee FROM borrowers LEFT JOIN categories ON borrowers.categorycode = categories.categorycode WHERE borrowernumber = ?
    };
    my $issue_qry = qq{
SELECT COUNT(*) FROM items
LEFT JOIN issues USING (itemnumber)
WHERE items.biblionumber=? AND issues.issue_id IS NULL
    };
    my $holds_qry = qq{
SELECT COUNT(*) FROM reserves WHERE biblionumber=? AND borrowernumber<>?
    };

    my $dbh = C4::Context->dbh;
    my ($fee) = $dbh->selectrow_array( $borquery, undef, ($borrowernumber) );
    $fee += 0;
    my $hold_fee_mode = C4::Context->preference('HoldFeeMode') || 'not_always';
    if ( $fee and $fee > 0 and $hold_fee_mode eq 'not_always' ) {

        # This is a reconstruction of the old code:
        # Compare number of items with items issued, and optionally check holds
        # If not all items are issued and there are no holds: charge no fee
        # NOTE: Lost, damaged, not-for-loan, etc. are just ignored here
        my ( $notissued, $reserved );
        ($notissued) = $dbh->selectrow_array(
            $issue_qry, undef,
            ($biblionumber)
        );
        if ( $notissued == 0 ) {

            # all items are issued
            ($reserved) = $dbh->selectrow_array(
                $holds_qry, undef,
                ( $biblionumber, $borrowernumber )
            );
            $fee = 0 if $reserved == 0;
        } else {
            $fee = 0;
        }
    }
    return $fee;
}

=head2 GetReserveStatus

  $reservestatus = GetReserveStatus($itemnumber);

Takes an itemnumber and returns the status of the reserve placed on it.
If several reserves exist, the reserve with the lower priority is given.

=cut

## FIXME: I don't think this does what it thinks it does.
## It only ever checks the first reserve result, even though
## multiple reserves for that bib can have the itemnumber set
## the sub is only used once in the codebase.
sub GetReserveStatus {
    my ($itemnumber) = @_;

    my $dbh = C4::Context->dbh;

    my ( $sth, $found, $priority );
    if ($itemnumber) {
        $sth = $dbh->prepare("SELECT found, priority FROM reserves WHERE itemnumber = ? order by priority LIMIT 1");
        $sth->execute($itemnumber);
        ( $found, $priority ) = $sth->fetchrow_array;
    }

    if ( defined $found ) {
        return 'Waiting'    if $found eq 'W' and $priority == 0;
        return 'Processing' if $found eq 'P';
        return 'Finished'   if $found eq 'F';
    }

    return 'Reserved' if defined $priority && $priority > 0;

    return '';    # empty string here will remove need for checking undef, or less log lines
}

=head2 CheckReserves

  ($status, $matched_reserve, $possible_reserves) = &CheckReserves($item);
  ($status, $matched_reserve, $possible_reserves) = &CheckReserves($item, $lookahead);

Find a book in the reserves.

C<$item> is the book's item.
C<$lookahead> is the number of days to look in advance for future reserves.

As I understand it, C<&CheckReserves> looks for the given item in the
reserves. If it is found, that's a match, and C<$status> is set to
C<Waiting>.

Otherwise, it finds the most important item in the reserves with the
same biblio number as this book (I'm not clear on this) and returns it
with C<$status> set to C<Reserved>.

C<&CheckReserves> returns a two-element list:

C<$status> is either C<Waiting>, C<Reserved> (see above), or 0.

C<$reserve> is the reserve item that matched. It is a
reference-to-hash whose keys are mostly the fields of the reserves
table in the Koha database.

=cut

sub CheckReserves {
    my ( $item, $lookahead_days, $ignore_borrowers ) = @_;

    # note: we get the itemnumber because we might have started w/ just the barcode.  Now we know for sure we have it.

    return unless $item;    # bail if we got nothing.

    return if ( $item->damaged && !C4::Context->preference('AllowHoldsOnDamagedItems') );

    # if item is not for loan it cannot be reserved either.....
    # except where items.notforloan < 0 :  This indicates the item is holdable.

    my @SkipHoldTrapOnNotForLoanValue = split( '\|', C4::Context->preference('SkipHoldTrapOnNotForLoanValue') );
    return if grep { $_ eq $item->notforloan } @SkipHoldTrapOnNotForLoanValue;

    my $dont_trap = C4::Context->preference('TrapHoldsOnOrder') ? $item->notforloan > 0 : $item->notforloan;
    if ( !$dont_trap ) {
        my $effective_item_type = $item->effective_itemtype;

        my $item_type = Koha::ItemTypes->find($effective_item_type);
        return
            if $item_type && $item_type->notforloan;
    } else {
        return;
    }

    # Find this item in the reserves
    my @reserves = _Findgroupreserve( $item->biblionumber, $item->itemnumber, $lookahead_days, $ignore_borrowers );

    # $priority and $highest are used to find the most important item
    # in the list returned by &_Findgroupreserve. (The lower $priority,
    # the more important the item.)
    # $highest is the most important item we've seen so far.
    my $highest;

    if ( scalar @reserves ) {
        my $LocalHoldsPriority              = C4::Context->preference('LocalHoldsPriority');
        my $LocalHoldsPriorityPatronControl = C4::Context->preference('LocalHoldsPriorityPatronControl');
        my $LocalHoldsPriorityItemControl   = C4::Context->preference('LocalHoldsPriorityItemControl');
        my $priority                        = 10000000;

        foreach my $res (@reserves) {
            if ( $res->{'found'} && $res->{'found'} eq 'W' ) {
                return ( "Waiting", $res, \@reserves );    # Found it, it is waiting
            } elsif ( $res->{'found'} && $res->{'found'} eq 'P' ) {
                return ( "Processing", $res, \@reserves );    # Found determined hold, e. g. the transferred one
            } elsif ( $res->{'found'} && $res->{'found'} eq 'T' ) {
                return ( "Transferred", $res, \@reserves );    # Found determined hold, e. g. the transferred one
            } else {
                my $patron;
                my $local_hold_match;
                my $local_hold_group_match;
                if ( $LocalHoldsPriority ne 'None' ) {
                    $patron = Koha::Patrons->find( $res->{borrowernumber} );

                    unless ( $item->exclude_from_local_holds_priority
                        || $patron->category->exclude_from_local_holds_priority )
                    {
                        my $local_holds_priority_item_branchcode = $item->$LocalHoldsPriorityItemControl;
                        my $local_holds_priority_patron_branchcode =
                              ( $LocalHoldsPriorityPatronControl eq 'PickupLibrary' ) ? $res->{branchcode}
                            : ( $LocalHoldsPriorityPatronControl eq 'HomeLibrary' )   ? $patron->branchcode
                            :                                                           undef;
                        if ( $LocalHoldsPriority eq 'GiveLibrary' || $LocalHoldsPriority eq 'GiveLibraryAndGroup' )
                        {    #Check the library first
                            $local_hold_match =
                                $local_holds_priority_item_branchcode eq $local_holds_priority_patron_branchcode;
                            if ( !$local_hold_match && $LocalHoldsPriority eq ('GiveLibraryAndGroup') )
                            {    # If there's no match at the library level, check hold groups
                                $local_hold_group_match =
                                    Koha::Libraries->find( { branchcode => $local_holds_priority_item_branchcode } )
                                    ->validate_hold_sibling(
                                    { branchcode => $local_holds_priority_patron_branchcode } );
                            }
                        }
                        if ( $LocalHoldsPriority eq 'GiveLibraryGroup' ) {    #Check only the group
                            $local_hold_group_match =
                                Koha::Libraries->find( { branchcode => $local_holds_priority_item_branchcode } )
                                ->validate_hold_sibling( { branchcode => $local_holds_priority_patron_branchcode } );
                        }
                    }
                }

                # See if this item is more important than what we've got so far
                if (   ( $res->{'priority'} && $res->{'priority'} < $priority )
                    || $local_hold_match
                    || $local_hold_group_match )
                {
                    next
                        if $res->{item_group_id}
                        && ( !$item->item_group || $item->item_group->id != $res->{item_group_id} );
                    next if $res->{itemtype} && $res->{itemtype} ne $item->effective_itemtype;
                    $patron //= Koha::Patrons->find( $res->{borrowernumber} );
                    my $branch         = Koha::Policy::Holds->holds_control_library( $item, $patron );
                    my $branchitemrule = C4::Circulation::GetBranchItemRule( $branch, $item->effective_itemtype );
                    next if ( $branchitemrule->{'holdallowed'} eq 'not_allowed' );
                    next
                        if ( ( $branchitemrule->{'holdallowed'} eq 'from_home_library' )
                        && ( $item->homebranch ne $patron->branchcode ) );
                    my $library = Koha::Libraries->find( { branchcode => $item->homebranch } );
                    next
                        if ( ( $branchitemrule->{'holdallowed'} eq 'from_local_hold_group' )
                        && ( !$library->validate_hold_sibling( { branchcode => $patron->branchcode } ) ) );
                    my $hold_fulfillment_policy = $branchitemrule->{hold_fulfillment_policy};
                    next
                        if ( ( $hold_fulfillment_policy eq 'holdgroup' )
                        && ( !$library->validate_hold_sibling( { branchcode => $res->{branchcode} } ) ) );
                    next
                        if ( ( $hold_fulfillment_policy eq 'homebranch' )
                        && ( $res->{branchcode} ne $item->$hold_fulfillment_policy ) );
                    next
                        if ( ( $hold_fulfillment_policy eq 'holdingbranch' )
                        && ( $res->{branchcode} ne $item->$hold_fulfillment_policy ) );
                    next unless $item->can_be_transferred( { to => Koha::Libraries->find( $res->{branchcode} ) } );
                    $priority = $res->{'priority'};
                    $highest  = $res;
                    last
                        if $local_hold_match
                        || ( ( $LocalHoldsPriority eq 'GiveLibraryGroup' ) && $local_hold_group_match );
                    next if $local_hold_group_match;
                }
            }
        }
    }

    # If we get this far, then no exact match was found.
    # We return the most important (i.e. next) reservation.
    if ($highest) {
        $highest->{'itemnumber'} = $item->itemnumber;
        return ( "Reserved", $highest, \@reserves );
    }

    return ('');
}

=head2 CancelExpiredReserves

    CancelExpiredReserves();
    CancelExpiredReserves($cancellation_reason);

Cancels all reserves with an expiration date from before today.

When the ExpireReservesOnHolidays system preference is disabled (0), implements
sophisticated holiday logic to handle various edge cases:

=head3 Use Cases and Logic

=over 4

=item B<Case 1: Hold expires today on a holiday>

If a hold expires today and today is a holiday, the hold is NOT cancelled.
This respects the library's policy of not processing cancellations on holidays.

Example: Hold expires on Christmas Day, script runs on Christmas Day => Hold preserved

=item B<Case 2: Hold expired in the past, script runs on business day>

If a hold expired in the past (regardless of whether the expiration date was a holiday),
and today is a business day, the hold IS cancelled.

Example: Hold expired on Christmas 2023, script runs in August 2024 => Hold cancelled

=item B<Case 3: Hold expired in the past, script runs on holiday, no business days missed>

If a hold expired recently and today is a holiday, but no business days have passed
since expiration, the hold is NOT cancelled.

Example: Hold expires Friday, script runs Saturday (holiday) => Hold preserved

=item B<Case 4: Hold expired in the past, script runs on holiday, business days were missed>

If a hold expired in the past and today is a holiday, but business days have passed
since expiration (due to server downtime, cron failures, etc.), the hold IS cancelled
retrospectively to prevent holds from remaining active indefinitely.

Example: Hold expires Monday, server down Tue-Wed (business days), script runs Thursday (holiday) => Hold cancelled

=item B<Case 5: ExpireReservesOnHolidays enabled>

When ExpireReservesOnHolidays is enabled (1), all expired holds are cancelled
regardless of holidays, maintaining the original simple behavior.

=back

=head3 Parameters

=over 4

=item $cancellation_reason (optional)

Optional cancellation reason to be recorded in the hold's cancellation_reason field.

=back

This logic ensures that:
- Library holiday policies are respected
- Holds don't remain active indefinitely due to technical issues
- The system is robust against server downtime and cron failures
- Behavior is predictable and well-defined for all scenarios

=cut

sub CancelExpiredReserves {
    my $cancellation_reason = shift;
    my $today               = dt_from_string();
    my $cancel_on_holidays  = C4::Context->preference('ExpireReservesOnHolidays');
    my $expireWaiting       = C4::Context->preference('ExpireReservesMaxPickUpDelay');

    my $dtf    = Koha::Database->new->schema->storage->datetime_parser;
    my $params = {
        -or => [
            { expirationdate         => { '<', $dtf->format_date($today) } },
            { patron_expiration_date => { '<' => $dtf->format_date($today) } }
        ]
    };

    $params->{found} = [ { '!=', 'W' }, undef ] unless $expireWaiting;

    # FIXME To move to Koha::Holds->search_expired (?)
    my $holds = Koha::Holds->search($params);

    my $cache = Koha::Cache::Memory::Lite->get_instance();

    while ( my $hold = $holds->next ) {
        my $cache_key = sprintf "Calendar_CancelExpiredReserves:%s", $hold->branchcode;
        my $calendar  = $cache->get_from_cache($cache_key);
        if ( !$calendar ) {
            $calendar = Koha::Calendar->new( branchcode => $hold->branchcode );
            $cache->set_in_cache( $cache_key, $calendar );
        }

        # Get the actual expiration date for this hold
        my $expiration_date = $hold->expirationdate || $hold->patron_expiration_date;

        # When ExpireReservesOnHolidays is disabled, implement proper holiday logic:
        if ( !$cancel_on_holidays && $expiration_date ) {
            my $expiration_dt = dt_from_string($expiration_date);

            # Check if hold expired today
            my $expired_today = $expiration_dt->ymd eq $today->ymd;

            if ($expired_today) {

                # Rule 1: Don't cancel holds that expired TODAY if today is a holiday
                next if $calendar->is_holiday($today);
            } else {

                # Rule 2: For holds that expired in the past, check for missed business days
                if ( $calendar->is_holiday($today) ) {

                    # If today is a holiday, check if business days were missed since expiration
                    my $days_since_expiration = $today->delta_days($expiration_dt)->in_units('days');

                    if ( $days_since_expiration > 0 ) {

                        # Use Calendar's has_business_days_between for cleaner logic
                        my $business_days_missed = $calendar->has_business_days_between( $expiration_dt, $today );

                        # Rule 3: If business days were missed, cancel retrospectively even on holidays
                        if ( !$business_days_missed ) {

                            # No business days were missed, skip cancellation
                            next;
                        }

                        # If business days were missed, continue with cancellation
                    } else {

                        # This shouldn't happen (expired_today would be true), but skip to be safe
                        next;
                    }
                }

                # If today is a business day, cancel expired holds from the past
            }
        }

        my $cancel_params = {};
        $cancel_params->{cancellation_reason} = $cancellation_reason if defined($cancellation_reason);
        if ( defined( $hold->found ) && $hold->found eq 'W' ) {
            $cancel_params->{charge_cancel_fee} = 1;
        }
        $cancel_params->{autofill} = C4::Context->preference('ExpireReservesAutoFill');
        $hold->cancel($cancel_params);
    }
}

=head2 AutoUnsuspendReserves

  AutoUnsuspendReserves();

Unsuspends all suspended reserves with a suspend_until date from before today.

=cut

sub AutoUnsuspendReserves {
    my $today = dt_from_string();

    my @holds = Koha::Holds->search( { suspend_until => { '<=' => $today->ymd() } } )->as_list;

    map { $_->resume() } @holds;
}

=head2 ModReserve

  ModReserve({ rank => $rank,
               reserve_id => $reserve_id,
               branchcode => $branchcode
               [, itemnumber => $itemnumber ]
               [, biblionumber => $biblionumber, $borrowernumber => $borrowernumber ]
              });

Change a hold request's priority or cancel it.

C<$rank> specifies the effect of the change.  If C<$rank>
is 'n', nothing happens.  This corresponds to leaving a
request alone when changing its priority in the holds queue
for a bib.

If C<$rank> is 'del', the hold request is cancelled.

If C<$rank> is an integer greater than zero, the priority of
the request is set to that value.  Since priority != 0 means
that the item is not waiting on the hold shelf, setting the
priority to a non-zero value also sets the request's found
status and waiting date to NULL.

If the hold is 'found' (waiting, in-transit, processing) the
only field that can be updated is the expiration date.

The optional C<$itemnumber> parameter is used only when
C<$rank> is a non-zero integer; if supplied, the itemnumber
of the hold request is set accordingly; if omitted, the itemnumber
is cleared.

B<FIXME:> Note that the forgoing can have the effect of causing
item-level hold requests to turn into title-level requests.  This
will be fixed once reserves has separate columns for requested
itemnumber and supplying itemnumber.

=cut

sub ModReserve {
    my ($params) = @_;

    my $rank                = $params->{'rank'};
    my $reserve_id          = $params->{'reserve_id'};
    my $branchcode          = $params->{'branchcode'};
    my $itemnumber          = $params->{'itemnumber'};
    my $suspend_until       = $params->{'suspend_until'};
    my $borrowernumber      = $params->{'borrowernumber'};
    my $biblionumber        = $params->{'biblionumber'};
    my $cancellation_reason = $params->{'cancellation_reason'};
    my $date                = $params->{expirationdate};

    return if defined $rank && $rank eq "n";

    return unless ( $reserve_id || ( $borrowernumber && ( $biblionumber || $itemnumber ) ) );

    my $hold;
    unless ($reserve_id) {
        my $holds = Koha::Holds->search(
            { biblionumber => $biblionumber, borrowernumber => $borrowernumber, itemnumber => $itemnumber } );
        return unless $holds->count;    # FIXME Should raise an exception
        $hold       = $holds->next;
        $reserve_id = $hold->reserve_id;
    }

    $hold ||= Koha::Holds->find($reserve_id);

    # FIXME Other calls may fail
    Koha::Exceptions::ObjectNotFound->throw( 'No hold with id ' . $reserve_id ) unless $hold;

    my $original = C4::Context->preference('HoldsLog') ? $hold->unblessed : undef;

    if ( $rank eq "del" ) {
        $hold->cancel( { cancellation_reason => $cancellation_reason } );
    } elsif ( $hold->found && $hold->priority eq '0' && $date ) {

        # The only column that can be updated for a found hold is the expiration date
        $hold->expirationdate($date)->store();

        logaction( 'HOLDS', 'MODIFY', $hold->reserve_id, $hold, undef, $original )
            if C4::Context->preference('HoldsLog');
    } elsif ( $rank =~ /^\d+/ and $rank > 0 ) {
        my $properties = {
            priority    => $rank,
            branchcode  => $branchcode,
            itemnumber  => $itemnumber,
            found       => undef,
            waitingdate => undef
        };
        if ( exists $params->{reservedate} ) {
            $properties->{reservedate} = $params->{reservedate} || undef;
        }
        if ( exists $params->{expirationdate} ) {
            $properties->{expirationdate} = $params->{expirationdate} || undef;
        }

        $hold->set($properties)->store();

        if ( defined($suspend_until) ) {
            if ($suspend_until) {
                $hold->suspend_hold($suspend_until);
            } else {

                # If the hold is suspended leave the hold suspended, but convert it to an indefinite hold.
                # If the hold is not suspended, this does nothing.
                $hold->set( { suspend_until => undef } )->store();
            }
        }

        _FixPriority( { reserve_id => $reserve_id, rank => $rank } );

        logaction( 'HOLDS', 'MODIFY', $hold->reserve_id, $hold, undef, $original )
            if C4::Context->preference('HoldsLog');
    }
}

=head2 ModReserveStatus

  &ModReserveStatus($itemnumber, $newstatus);

Update the reserve status for the active (priority=0) reserve.

$itemnumber is the itemnumber the reserve is on

$newstatus is the new status.

=cut

sub ModReserveStatus {

    #first : check if we have a reservation for this item .
    my ( $itemnumber, $newstatus ) = @_;
    my $dbh = C4::Context->dbh;

    my $query =
        "UPDATE reserves SET found = ?, waitingdate = NOW() WHERE itemnumber = ? AND found IS NULL AND priority = 0";
    my $sth_set = $dbh->prepare($query);
    $sth_set->execute( $newstatus, $itemnumber );

    my $item = Koha::Items->find($itemnumber);
    if (   $item->location
        && $item->location eq 'CART'
        && ( !$item->permanent_location || $item->permanent_location ne 'CART' )
        && $newstatus )
    {
        CartToShelf($itemnumber);
    }
}

=head2 ModReserveAffect

  &ModReserveAffect($itemnumber,$borrowernumber,$diffBranchSend,$reserve_id, $desk_id, $notify_library);

This function affect an item and a status for a given reserve, either fetched directly
by record_id, or by borrowernumber and itemnumber or biblionumber. If only biblionumber
is given, only first reserve returned is affected, which is ok for anything but
multi-item holds.

if $transferToDo is not set, then the status is set to "Waiting" as well.
otherwise, a transfer is on the way, and the end of the transfer will
take care of the waiting status

This function also removes any entry of the hold in holds queue table.

=cut

sub ModReserveAffect {
    my ( $itemnumber, $borrowernumber, $transferToDo, $reserve_id, $desk_id, $notify_library ) = @_;
    my $dbh = C4::Context->dbh;

    # we want to attach $itemnumber to $borrowernumber, find the biblionumber
    # attached to $itemnumber
    my $sth = $dbh->prepare("SELECT biblionumber FROM items WHERE itemnumber=?");
    $sth->execute($itemnumber);
    my ($biblionumber) = $sth->fetchrow;

    # get request - need to find out if item is already
    # waiting in order to not send duplicate hold filled notifications

    my $hold;

    # Find hold by id if we have it
    $hold = Koha::Holds->find($reserve_id) if $reserve_id;

    # Find item level hold for this item if there is one
    $hold ||= Koha::Holds->search( { borrowernumber => $borrowernumber, itemnumber => $itemnumber } )->next();

    # Find record level hold if there is no item level hold
    $hold ||= Koha::Holds->search( { borrowernumber => $borrowernumber, biblionumber => $biblionumber } )->next();

    return unless $hold;

    my $original = $hold->unblessed;

    my $already_on_shelf = $hold->found && $hold->found eq 'W';

    $hold->itemnumber($itemnumber);

    if ($transferToDo) {
        $hold->set_transfer();
    } elsif ( C4::Context->preference('HoldsNeedProcessingSIP')
        && C4::Context->interface eq 'sip'
        && !$already_on_shelf )
    {
        $hold->set_processing();
    } else {
        $hold->set_waiting($desk_id);
        _koha_notify_reserve( $hold->reserve_id ) unless $already_on_shelf;

        # Complete transfer if one exists
        my $transfer = $hold->item->get_transfer;
        $transfer->receive if $transfer;
    }

    _koha_notify_hold_changed($hold) if $notify_library;

    _FixPriority( { biblionumber => $biblionumber } );
    my $item = Koha::Items->find($itemnumber);
    if (   $item->location
        && $item->location eq 'CART'
        && ( !$item->permanent_location || $item->permanent_location ne 'CART' ) )
    {
        CartToShelf($itemnumber);
    }

    my $std = $dbh->prepare(
        q{
        DELETE  q, t
        FROM    tmp_holdsqueue q
        INNER JOIN hold_fill_targets t
        ON  q.borrowernumber = t.borrowernumber
            AND q.biblionumber = t.biblionumber
            AND q.itemnumber = t.itemnumber
            AND q.item_level_request = t.item_level_request
            AND q.holdingbranch = t.source_branchcode
        WHERE t.reserve_id = ?
    }
    );
    $std->execute( $hold->reserve_id );

    logaction( 'HOLDS', 'MODIFY', $hold->reserve_id, $hold, undef, $original )
        if C4::Context->preference('HoldsLog');

    return;
}

=head2 ModReserveCancelAll

  ($messages,$nextreservinfo) = &ModReserveCancelAll($itemnumber,$borrowernumber,$reason);

function to cancel reserve and check other reserves

=cut

sub ModReserveCancelAll {
    my $messages;
    my $nextreservinfo;
    my ( $itemnumber, $borrowernumber, $cancellation_reason ) = @_;
    my $item = Koha::Items->find($itemnumber);

    #step 1 : cancel the reservation
    my $holds = Koha::Holds->search( { itemnumber => $itemnumber, borrowernumber => $borrowernumber } );
    return unless $holds->count;
    $holds->next->cancel( { cancellation_reason => $cancellation_reason } );

    #step 2 check for other reserves on this item
    ( undef, $nextreservinfo, undef ) = CheckReserves($item);

    if ($nextreservinfo) {
        if ( $item->holdingbranch ne $nextreservinfo->{'branchcode'} ) {
            $messages->{'transfert'} = $nextreservinfo->{'branchcode'};
        } else {
            $messages->{'waiting'} = 1;
        }
    }

    return ( $messages, $nextreservinfo->{borrowernumber} );
}

=head2 ModReserveMinusPriority

  &ModReserveMinusPriority($itemnumber,$borrowernumber,$biblionumber)

Reduce the values of queued list

=cut

sub ModReserveMinusPriority {
    my ( $itemnumber, $reserve_id ) = @_;

    #first step update the value of the first person on reserve
    my $dbh   = C4::Context->dbh;
    my $query = "
        UPDATE reserves
        SET    priority = 0 , itemnumber = ?
        WHERE  reserve_id = ?
    ";
    my $sth_upd = $dbh->prepare($query);
    $sth_upd->execute( $itemnumber, $reserve_id );

    # second step update all others reserves
    _FixPriority( { reserve_id => $reserve_id, rank => '0' } );
}

=head2 IsAvailableForItemLevelRequest

  my $is_available = IsAvailableForItemLevelRequest( $item_record, $borrower_record, $pickup_branchcode );

Checks whether a given item record is available for an
item-level hold request.  An item is available if

* it is not lost AND
* it is not damaged AND
* it is not withdrawn AND
* a waiting or in transit reserve is placed on
* does not have a not for loan value > 0

Need to check the issuingrules onshelfholds column,
if this is set items on the shelf can be placed on hold

Note that IsAvailableForItemLevelRequest() does not
check if the staff operator is authorized to place
a request on the item - in particular,
this routine does not check IndependentBranches
and canreservefromotherbranches.

Note also that this subroutine does not checks smart
rules limits for item by reservesallowed/holds_per_record
values, this complemented in calling code with calls and
checks with CanItemBeReserved or CanBookBeReserved.

=cut

sub IsAvailableForItemLevelRequest {
    my $item              = shift;
    my $patron            = shift;
    my $pickup_branchcode = shift;

    my $dbh = C4::Context->dbh;

    # must check the notforloan setting of the itemtype
    # FIXME - a lot of places in the code do this
    #         or something similar - need to be
    #         consolidated
    my $itemtype = $item->effective_itemtype;
    return 0
        unless defined $itemtype;
    my $notforloan_per_itemtype = Koha::ItemTypes->find($itemtype)->notforloan;

    return 0
        if $notforloan_per_itemtype
        || $item->itemlost
        || $item->notforloan > 0
        ||    # item with negative or zero notforloan value is holdable
        $item->withdrawn
        || ( $item->damaged && !C4::Context->preference('AllowHoldsOnDamagedItems') );

    if ($pickup_branchcode) {
        my $destination = Koha::Libraries->find($pickup_branchcode);
        return 0 unless $destination;
        return 0 unless $destination->pickup_location;
        return 0 unless $item->can_be_transferred( { to => $destination } );
        my $reserves_control_branch = Koha::Policy::Holds->holds_control_library( $item, $patron );
        my $branchitemrule          = C4::Circulation::GetBranchItemRule( $reserves_control_branch, $item->itype );
        my $home_library            = Koha::Libraries->find( { branchcode => $item->homebranch } );
        return 0
            unless $branchitemrule->{hold_fulfillment_policy} ne 'holdgroup'
            || $home_library->validate_hold_sibling( { branchcode => $pickup_branchcode } );
    }

    my $on_shelf_holds = Koha::CirculationRules->get_onshelfholds_policy( { item => $item, patron => $patron } );

    if ( $on_shelf_holds == 1 ) {
        return 1;
    } elsif ( $on_shelf_holds == 2 ) {

        # These calculations work at the biblio level, and can be expensive
        # we use the in-memory cache to avoid calling once per item when looping items on a biblio

        my $memory_cache = Koha::Cache::Memory::Lite->get_instance();
        my $cache_key    = sprintf "ItemsAnyAvailableAndNotRestricted:%s:%s", $patron->id, $item->biblionumber;

        my $any_available = $memory_cache->get_from_cache($cache_key);
        return $any_available ? 0 : 1 if defined($any_available);

        $any_available =
            ItemsAnyAvailableAndNotRestricted( { biblionumber => $item->biblionumber, patron => $patron } );
        $memory_cache->set_in_cache( $cache_key, $any_available );
        return $any_available ? 0 : 1;

    } else {  # on_shelf_holds == 0 "If any unavailable" (the description is rather cryptic and could still be improved)
        return $item->notforloan < 0 || $item->onloan || $item->holds->filter_by_found->count;
    }
}

=head2 ItemsAnyAvailableAndNotRestricted

  ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron });

This function checks all items for specified biblionumber (numeric) against patron (object)
and returns true (1) if at least one item available for loan/check out/present/not held
and also checks other parameters logic which not restricts item for hold at all (for ex.
AllowHoldsOnDamagedItems or 'holdallowed' own/sibling library)

=cut

sub ItemsAnyAvailableAndNotRestricted {
    my $param = shift;

    my @items = Koha::Items->search( { biblionumber => $param->{biblionumber} } )->as_list;

    foreach my $i (@items) {
        my $reserves_control_branch = Koha::Policy::Holds->holds_control_library( $i, $param->{patron} );
        my $branchitemrule          = C4::Circulation::GetBranchItemRule( $reserves_control_branch, $i->itype );
        my $item_library            = Koha::Libraries->find( { branchcode => $i->homebranch } );

        # we can return (end the loop) when first one found:
        return 1
            unless $i->itemlost
            || $i->notforloan    # items with non-zero notforloan cannot be checked out
            || $i->withdrawn
            || $i->onloan
            || $i->holds->filter_by_found->count
            || ( $i->damaged
            && !C4::Context->preference('AllowHoldsOnDamagedItems') )
            || Koha::ItemTypes->find( $i->effective_itemtype() )->notforloan
            || $branchitemrule->{holdallowed} eq 'from_home_library' && $param->{patron}->branchcode ne $i->homebranch
            || $branchitemrule->{holdallowed} eq 'from_local_hold_group'
            && !$item_library->validate_hold_sibling( { branchcode => $param->{patron}->branchcode } )
            || CanItemBeReserved( $param->{patron}, $i )->{status} ne 'OK';
    }

    return 0;
}

=head2 AlterPriority

  AlterPriority( $where, $reserve_id, $prev_priority, $next_priority, $first_priority, $last_priority );

This function changes a reserve's priority up, down, to the top, or to the bottom.
Input: $where is 'up', 'down', 'top' or 'bottom'. Biblionumber, Date reserve was placed

=cut

sub AlterPriority {
    my ( $where, $reserve_id, $prev_priority, $next_priority, $first_priority, $last_priority ) = @_;

    my $hold = Koha::Holds->find($reserve_id);
    return unless $hold;

    if ( $hold->cancellationdate ) {
        warn "I cannot alter the priority for reserve_id $reserve_id, the reserve has been cancelled ("
            . $hold->cancellationdate . ')';
        return;
    }

    if ( $where eq 'up' ) {
        return unless $prev_priority;
        _FixPriority( { reserve_id => $reserve_id, rank => $prev_priority } );
    } elsif ( $where eq 'down' ) {
        return unless $next_priority;
        _FixPriority( { reserve_id => $reserve_id, rank => $next_priority } );
    } elsif ( $where eq 'top' ) {
        _FixPriority( { reserve_id => $reserve_id, rank => $first_priority } );
    } elsif ( $where eq 'bottom' ) {
        _FixPriority( { reserve_id => $reserve_id, rank => $last_priority } );
    }

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $hold->biblionumber ] } )
        if C4::Context->preference('RealTimeHoldsQueue');

    # FIXME Should return the new priority
}

=head2 ToggleLowestPriority

  ToggleLowestPriority( $borrowernumber, $biblionumber );

This function sets the lowestPriority field to true if is false, and false if it is true.

=cut

sub ToggleLowestPriority {
    my ($reserve_id) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare("UPDATE reserves SET lowestPriority = NOT lowestPriority WHERE reserve_id = ?");
    $sth->execute($reserve_id);

    _FixPriority( { reserve_id => $reserve_id, rank => '999999' } );
}

=head2 SuspendAll

  SuspendAll(
      borrowernumber   => $borrowernumber,
      [ biblionumber   => $biblionumber, ]
      [ suspend_until  => $suspend_until, ]
      [ suspend        => $suspend ]
  );

  This function accepts a set of hash keys as its parameters.
  It requires either borrowernumber or biblionumber, or both.

  suspend_until is wholly optional.

=cut

sub SuspendAll {
    my %params = @_;

    my $borrowernumber = $params{'borrowernumber'} || undef;
    my $biblionumber   = $params{'biblionumber'}   || undef;
    my $suspend_until  = $params{'suspend_until'}  || undef;
    my $suspend        = defined( $params{'suspend'} ) ? $params{'suspend'} : 1;

    return unless ( $borrowernumber || $biblionumber );

    my $params;
    $params->{found}          = undef;
    $params->{borrowernumber} = $borrowernumber if $borrowernumber;
    $params->{biblionumber}   = $biblionumber   if $biblionumber;

    my @holds = Koha::Holds->search($params)->as_list;

    if ($suspend) {
        map { $_->suspend_hold($suspend_until) } @holds;
    } else {
        map { $_->resume() } @holds;
    }
}

=head2 _FixPriority

  _FixPriority({
    reserve_id => $reserve_id,
    [rank => $rank,]
    [ignoreSetLowestRank => $ignoreSetLowestRank]
  });

  or

  _FixPriority({ biblionumber => $biblionumber});

This routine adjusts the priority of a hold request and holds
on the same bib.

In the first form, where a reserve_id is passed, the priority of the
hold is set to supplied rank, and other holds for that bib are adjusted
accordingly.  If the rank is "del", the hold is cancelled.  If no rank
is supplied, all of the holds on that bib have their priority adjusted
as if the second form had been used.

In the second form, where a biblionumber is passed, the holds on that
bib (that are not captured) are sorted in order of increasing priority,
then have reserves.priority set so that the first non-captured hold
has its priority set to 1, the second non-captured hold has its priority
set to 2, and so forth.

In both cases, holds that have the lowestPriority flag on are have their
priority adjusted to ensure that they remain at the end of the line.

Note that the ignoreSetLowestRank parameter is meant to be used only
when _FixPriority calls itself.

=cut

sub _FixPriority {
    my ($params)            = @_;
    my $reserve_id          = $params->{reserve_id};
    my $rank                = $params->{rank} // '';
    my $ignoreSetLowestRank = $params->{ignoreSetLowestRank};
    my $biblionumber        = $params->{biblionumber};

    my $dbh = C4::Context->dbh;

    my $hold;
    if ($reserve_id) {
        $hold = Koha::Holds->find($reserve_id);
        if ( !defined $hold ) {

            # may have already been checked out and hold fulfilled
            require Koha::Old::Holds;
            $hold = Koha::Old::Holds->find($reserve_id);
        }
        return unless $hold;
    }

    unless ($biblionumber) {    # FIXME This is a very weird API
        $biblionumber = $hold->biblionumber;
    }

    if ( $rank eq "del" ) {     # FIXME will crash if called without $hold
        $hold->cancel;
    } elsif ( $reserve_id && ( $rank eq "W" || $rank eq "0" ) ) {

        # make sure priority for waiting or in-transit items is 0
        my $query = "
            UPDATE reserves
            SET    priority = 0
            WHERE reserve_id = ?
            AND found IN ('W', 'T', 'P')
        ";
        my $sth = $dbh->prepare($query);
        $sth->execute($reserve_id);
    }
    my @priority;

    # get what's left
    my $query = "
        SELECT reserve_id, borrowernumber, reservedate
        FROM   reserves
        WHERE  biblionumber   = ?
          AND  ((found <> 'W' AND found <> 'T' AND found <> 'P') OR found IS NULL)
        ORDER BY priority ASC
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    while ( my $line = $sth->fetchrow_hashref ) {
        push( @priority, $line );
    }

    # FIXME This whole sub must be rewritten, especially to highlight what is done when reserve_id is not given
    # To find the matching index
    my $i;
    my $key = -1;    # to allow for 0 to be a valid result
    for ( $i = 0 ; $i < @priority ; $i++ ) {
        if ( $reserve_id && $reserve_id == $priority[$i]->{'reserve_id'} ) {
            $key = $i;    # save the index
            last;
        }
    }

    # if index exists in array then move it to new position
    if ( $key > -1 && $rank ne 'del' && $rank > 0 ) {
        my $new_rank    = $rank - 1;                      # $new_rank is what you want the new index to be in the array
        my $moving_item = splice( @priority, $key, 1 );
        $new_rank = scalar @priority if $new_rank > scalar @priority;
        splice( @priority, $new_rank, 0, $moving_item );
    }

    # now fix the priority on those that are left....
    $query = "
        UPDATE reserves
        SET    priority = ?
        WHERE  reserve_id = ?
    ";
    $sth = $dbh->prepare($query);
    for ( my $j = 0 ; $j < @priority ; $j++ ) {
        $sth->execute(
            $j + 1,
            $priority[$j]->{'reserve_id'}
        );
    }

    unless ($ignoreSetLowestRank) {
        $sth = $dbh->prepare(
            "SELECT reserve_id FROM reserves WHERE lowestPriority = 1 AND biblionumber = ? ORDER BY priority");
        $sth->execute($biblionumber);
        while ( my $res = $sth->fetchrow_hashref() ) {
            _FixPriority(
                {
                    reserve_id          => $res->{'reserve_id'},
                    rank                => '999999',
                    ignoreSetLowestRank => 1
                }
            );
        }
    }
}

=head2 _Findgroupreserve

  @results = &_Findgroupreserve($biblionumber, $itemnumber, $lookahead, $ignore_borrowers);

Looks for a holds-queue based item-specific match first, then for a holds-queue title-level match, returning the
first match found.  If neither, then we look for non-holds-queue based holds.
Lookahead is the number of days to look in advance.

C<&_Findgroupreserve> returns :
C<@results> is an array of references-to-hash whose keys are mostly
fields from the reserves table of the Koha database, plus
C<biblioitemnumber>.

This routine with either return:
1 - Item specific holds from the holds queue
2 - Title level holds from the holds queue
3 - All holds for this biblionumber

All return values will respect any borrowernumbers passed as arrayref in $ignore_borrowers

=cut

sub _Findgroupreserve {
    my ( $biblionumber, $itemnumber, $lookahead, $ignore_borrowers ) = @_;
    my $dbh = C4::Context->dbh;

    # check for targeted match form the holds queue
    my $hold_target_query = qq{
        SELECT reserves.biblionumber        AS biblionumber,
               reserves.borrowernumber      AS borrowernumber,
               reserves.reservedate         AS reservedate,
               reserves.branchcode          AS branchcode,
               reserves.cancellationdate    AS cancellationdate,
               reserves.found               AS found,
               reserves.reservenotes        AS reservenotes,
               reserves.priority            AS priority,
               reserves.timestamp           AS timestamp,
               biblioitems.biblioitemnumber AS biblioitemnumber,
               reserves.itemnumber          AS itemnumber,
               reserves.reserve_id          AS reserve_id,
               reserves.itemtype            AS itemtype,
               reserves.non_priority        AS non_priority,
               reserves.item_group_id           AS item_group_id
        FROM reserves
        JOIN biblioitems USING (biblionumber)
        JOIN hold_fill_targets USING (reserve_id)
        WHERE found IS NULL
        AND priority > 0
        AND hold_fill_targets.itemnumber = ?
        AND reservedate <= DATE_ADD(NOW(),INTERVAL ? DAY)
        AND suspend = 0
        ORDER BY priority
    };
    my $sth = $dbh->prepare($hold_target_query);
    $sth->execute( $itemnumber, $lookahead || 0 );
    my @results;
    if ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data )
            unless any { $data->{borrowernumber} eq $_ } @$ignore_borrowers;
    }
    return @results if @results;

    my $query = qq{
        SELECT reserves.biblionumber               AS biblionumber,
               reserves.borrowernumber             AS borrowernumber,
               reserves.reservedate                AS reservedate,
               reserves.waitingdate                AS waitingdate,
               reserves.branchcode                 AS branchcode,
               reserves.cancellationdate           AS cancellationdate,
               reserves.found                      AS found,
               reserves.reservenotes               AS reservenotes,
               reserves.priority                   AS priority,
               reserves.timestamp                  AS timestamp,
               reserves.itemnumber                 AS itemnumber,
               reserves.reserve_id                 AS reserve_id,
               reserves.itemtype                   AS itemtype,
               reserves.non_priority               AS non_priority,
               reserves.item_group_id              AS item_group_id
        FROM reserves
        WHERE reserves.biblionumber = ?
          AND (reserves.itemnumber IS NULL OR reserves.itemnumber = ?)
          AND reserves.reservedate <= DATE_ADD(NOW(),INTERVAL ? DAY)
          AND suspend = 0
          ORDER BY priority
    };
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $itemnumber, $lookahead || 0 );
    @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data )
            unless any { $data->{borrowernumber} eq $_ } @$ignore_borrowers;
    }
    return @results;
}

=head2 _koha_notify_reserve

  _koha_notify_reserve( $hold->reserve_id );

Sends a notification to the patron that their hold has been filled (through
ModReserveAffect)

The letter code for this notice may be found using the following query:

    select distinct letter_code
    from message_transports
    inner join message_attributes using (message_attribute_id)
    where message_name = 'Hold_Filled'

This will probably sipmly be 'HOLD', but because it is defined in the database,
it is subject to addition or change.

The following tables are available within the notice:

    branches
    borrowers
    biblio
    biblioitems
    reserves
    items

=cut

sub _koha_notify_reserve {
    my $reserve_id = shift;

    my $hold           = Koha::Holds->find($reserve_id);
    my $borrowernumber = $hold->borrowernumber;

    my $patron = Koha::Patrons->find($borrowernumber);

    # Try to get the borrower's email address
    my $to_address = $patron->notice_email_address;

    my $messagingprefs = C4::Members::Messaging::GetMessagingPreferences(
        {
            borrowernumber => $borrowernumber,
            message_name   => 'Hold_Filled'
        }
    );

    my $library             = Koha::Libraries->find( $hold->branchcode );
    my $from_email_address  = $library->from_email_address;
    my $reply_email_address = $library->inbound_email_address;

    my %letter_params = (
        module     => 'reserves',
        branchcode => $hold->branchcode,
        lang       => $patron->lang,
        tables     => {
            'branches'    => $library->unblessed,
            'borrowers'   => $patron->unblessed,
            'biblio'      => $hold->biblionumber,
            'biblioitems' => $hold->biblionumber,
            'reserves'    => $hold->unblessed,
            'items'       => $hold->itemnumber,
        },
    );

    my $notification_sent =
        0;  #Keeping track if a Hold_filled message is sent. If no message can be sent, then default to a print message.
    my $do_not_lock       = ( exists $ENV{_} && $ENV{_} =~ m|prove| ) || $ENV{KOHA_TESTING};
    my $send_notification = sub {
        my ( $mtt, $letter_code, $wants_digest ) = (@_);
        return unless defined $letter_code;
        $letter_params{letter_code}            = $letter_code;
        $letter_params{message_transport_type} = $mtt;
        my $letter = C4::Letters::GetPreparedLetter(%letter_params);
        unless ($letter) {
            warn "Could not find a letter called '$letter_params{'letter_code'}' for $mtt in the 'reserves' module";
            return;
        }

        unless ($wants_digest) {
            C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $borrowernumber,
                    from_address           => $from_email_address,
                    reply_address          => $reply_email_address,
                    message_transport_type => $mtt,
                }
            );
        } else {
            C4::Context->dbh->do(q|LOCK TABLE message_queue READ|)  unless $do_not_lock;
            C4::Context->dbh->do(q|LOCK TABLE message_queue WRITE|) unless $do_not_lock;
            my $message = C4::Message->find_last_message( $patron->unblessed, $letter_code, $mtt );
            unless ($message) {
                C4::Context->dbh->do(q|UNLOCK TABLES|) unless $do_not_lock;
                C4::Message->enqueue( $letter, $patron, $mtt );
            } else {
                $message->append($letter);
                $message->update;
            }
            C4::Context->dbh->do(q|UNLOCK TABLES|) unless $do_not_lock;
        }
    };

    while ( my ( $mtt, $letter_code ) = each %{ $messagingprefs->{transports} } ) {
        next
            if (
            ( $mtt eq 'email'  and not $to_address )                # No email address
            or ( $mtt eq 'sms' and not $patron->smsalertnumber )    # No SMS number
            or ( $mtt eq 'itiva'
                and C4::Context->preference('TalkingTechItivaPhoneNotification')
            )                                                       # Notice is handled by TalkingTech_itiva_outbound.pl
            or ( $mtt eq 'phone' and not $patron->phone )           # No phone number to call
            );

        &$send_notification( $mtt, $letter_code, $messagingprefs->{wants_digest} );
        $notification_sent++;
    }

    #Making sure that a print notification is sent if no other transport types can be utilized.
    if ( !$notification_sent ) {
        &$send_notification( 'print', 'HOLD' );
    }

}

=head2 _koha_notify_hold_changed

  _koha_notify_hold_changed( $hold_object );

=cut

sub _koha_notify_hold_changed {
    my $hold = shift;

    my $patron  = $hold->patron;
    my $library = $hold->branch;

    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'reserves',
        letter_code => 'HOLD_CHANGED',
        branchcode  => $hold->branchcode,
        substitute  => { today => output_pref(dt_from_string) },
        tables      => {
            'branches'    => $library->unblessed,
            'borrowers'   => $patron->unblessed,
            'biblio'      => $hold->biblionumber,
            'biblioitems' => $hold->biblionumber,
            'reserves'    => $hold->unblessed,
            'items'       => $hold->itemnumber,
        },
    );

    return unless $letter;

    my $email = C4::Context->preference('ExpireReservesAutoFillEmail')
        || $library->inbound_email_address;

    C4::Letters::EnqueueLetter(
        {
            letter                 => $letter,
            borrowernumber         => $patron->id,
            message_transport_type => 'email',
            from_address           => $library->from_email_address,
            to_address             => $email,
        }
    );
}

=head2 _ShiftPriority

  $new_priority = _ShiftPriority( $biblionumber, $priority );

This increments the priority of all reserves after the one
with either the lowest date after C<$reservedate>
or the lowest priority after C<$priority>.

It effectively makes room for a new reserve to be inserted with a certain
priority, which is returned.

This is most useful when the reservedate can be set by the user.  It allows
the new reserve to be placed before other reserves that have a later
reservedate.  Since priority also is set by the form in reserves/request.pl
the sub accounts for that too.

=cut

sub _ShiftPriority {
    my ( $biblio, $new_priority ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "SELECT priority FROM reserves WHERE biblionumber = ? AND priority > ? ORDER BY priority ASC LIMIT 1";
    my $sth   = $dbh->prepare($query);
    $sth->execute( $biblio, $new_priority );
    my $min_priority = $sth->fetchrow;

    # if no such matches are found, $new_priority remains as original value
    $new_priority = $min_priority if ($min_priority);

    # Shift the priority up by one; works in conjunction with the next SQL statement
    $query = "UPDATE reserves
              SET priority = priority+1
              WHERE biblionumber = ?
              AND borrowernumber = ?
              AND reservedate = ?
              AND found IS NULL";
    my $sth_update = $dbh->prepare($query);

    # Select all reserves for the biblio with priority greater than $new_priority, and order greatest to least
    $query =
        "SELECT borrowernumber, reservedate FROM reserves WHERE priority >= ? AND biblionumber = ? ORDER BY priority DESC";
    $sth = $dbh->prepare($query);
    $sth->execute( $new_priority, $biblio );
    while ( my $row = $sth->fetchrow_hashref ) {
        $sth_update->execute( $biblio, $row->{borrowernumber}, $row->{reservedate} );
    }

    return $new_priority;    # so the caller knows what priority they wind up receiving
}

=head2 MoveReserve

  MoveReserve( $item, $patron, $cancelreserve )

Use when checking out an item to handle reserves
If $cancelreserve boolean is set to true, it will remove existing reserve

Parameters are:

=over 4

=item B<$item>: a I<Koha::Item> object

=item B<$patron>: a I<Koha::Patron> object

=item B<$cancelreserve>: a boolean telling if the existing hold should be removed

=back

=cut

sub MoveReserve {
    my ( $item, $patron, $cancelreserve ) = @_;

    $cancelreserve //= 0;

    my $lookahead = C4::Context->preference('ConfirmFutureHolds');    #number of days to look for future holds
    my ( $restype, $res, undef ) = CheckReserves( $item, $lookahead );

    if ( $res && $res->{borrowernumber} == $patron->borrowernumber ) {
        my $hold = Koha::Holds->find( $res->{reserve_id} );
        $hold->fill( { item_id => $item->id } );
    } else {

        # The item is reserved by someone else.
        # Find this item in the reserves

        my $lookahead_date = output_pref(
            {
                dt         => dt_from_string->add_duration( DateTime::Duration->new( days => $lookahead ) ),
                dateformat => 'iso', dateonly => 1
            }
        );
        my $hold = $patron->holds->search(
            {
                biblionumber => $item->biblionumber,
                reservedate  => { '<=' => $lookahead_date },
                -or          => [ item_level_hold => 0, itemnumber => $item->id ],
            },
            { order_by => 'priority' }
        )->next();

        if ($hold) {

            # The item is reserved by the current patron
            $hold->fill( { item_id => $item->id } );
        }

        $hold = Koha::Holds->find( $res->{reserve_id} );
        if ( $cancelreserve eq 'revert' ) {
            $hold->revert_found();
        } elsif ( $cancelreserve eq 'cancel' || $cancelreserve ) {    # cancel reserves on this item
            $hold->cancel;
        }
    }
}

=head2 MergeHolds

  MergeHolds($dbh,$to_biblio, $from_biblio);

This shifts the holds from C<$from_biblio> to C<$to_biblio> and reorders them by the date they were placed

=cut

sub MergeHolds {
    my ( $dbh, $to_biblio, $from_biblio ) = @_;
    my $sth = $dbh->prepare("SELECT count(*) as reserve_count FROM reserves WHERE biblionumber = ?");
    $sth->execute($from_biblio);
    if ( my $data = $sth->fetchrow_hashref() ) {

        # holds exist on old record, if not we don't need to do anything
        $sth = $dbh->prepare("UPDATE reserves SET biblionumber = ? WHERE biblionumber = ?");
        $sth->execute( $to_biblio, $from_biblio );

        # Reorder by date
        # don't reorder those already waiting

        $sth = $dbh->prepare(
            "SELECT * FROM reserves WHERE biblionumber = ? AND (found NOT IN ('W', 'T', 'P') OR found is NULL) ORDER BY reservedate ASC"
        );
        my $upd_sth = $dbh->prepare(
            "UPDATE reserves SET priority = ? WHERE biblionumber = ? AND borrowernumber = ?
        AND reservedate = ? AND (itemnumber = ? or itemnumber is NULL) "
        );
        $sth->execute($to_biblio);
        my $priority = 1;
        while ( my $reserve = $sth->fetchrow_hashref() ) {
            $upd_sth->execute(
                $priority,                    $to_biblio,
                $reserve->{'borrowernumber'}, $reserve->{'reservedate'},
                $reserve->{'itemnumber'}
            );
            $priority++;
        }
    }
}

=head2 ReserveSlip

ReserveSlip(
    {
        branchcode     => $branchcode,
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
        [ itemnumber   => $itemnumber, ]
        [ barcode      => $barcode, ]
    }
  )

Returns letter hash ( see C4::Letters::GetPreparedLetter ) or undef

The letter code will be HOLD_SLIP, and the following tables are
available within the slip:

    reserves
    branches
    borrowers
    biblio
    biblioitems
    items

=cut

sub ReserveSlip {
    my ($args)     = @_;
    my $branchcode = $args->{branchcode};
    my $reserve_id = $args->{reserve_id};
    my $itemnumber = $args->{itemnumber};

    my $hold = Koha::Holds->find($reserve_id);
    return unless $hold;

    my $patron  = $hold->borrower;
    my $reserve = $hold->unblessed;

    return C4::Letters::GetPreparedLetter(
        module      => 'circulation',
        letter_code => 'HOLD_SLIP',
        branchcode  => $branchcode,
        lang        => $patron->lang,
        tables      => {
            'reserves'    => $reserve,
            'branches'    => $reserve->{branchcode},
            'borrowers'   => $reserve->{borrowernumber},
            'biblio'      => $reserve->{biblionumber},
            'biblioitems' => $reserve->{biblionumber},
            'items'       => $reserve->{itemnumber} || $itemnumber,
        },
    );
}

=head2 CalculatePriority

    my $p = CalculatePriority($biblionumber, $resdate);

Calculate priority for a new reserve on biblionumber, placing it at
the end of the line of all holds whose start date falls before
the current system time and that are neither on the hold shelf
or in transit.

The reserve date parameter is optional; if it is supplied, the
priority is based on the set of holds whose start date falls before
the parameter value.

After calculation of this priority, it is recommended to call
_ShiftPriority. Note that this is currently done in
AddReserves.

=cut

sub CalculatePriority {
    my ( $biblionumber, $resdate ) = @_;

    my $sql = q{
        SELECT COUNT(*) FROM reserves
        WHERE biblionumber = ?
        AND   priority > 0
        AND   (found IS NULL OR found = '')
    };

    #skip found==W or found==T or found==P (waiting, transit or processing holds)
    if ($resdate) {
        $sql .= ' AND ( reservedate <= ? )';
    } else {
        $sql .= ' AND ( reservedate < NOW() )';
    }
    my $dbh = C4::Context->dbh();
    my @row = $dbh->selectrow_array(
        $sql,
        undef,
        $resdate ? ( $biblionumber, $resdate ) : ($biblionumber)
    );

    return @row ? $row[0] + 1 : 1;
}

=head2 GetMaxPatronHoldsForRecord

my $holds_per_record = ReservesControlBranch( $borrowernumber, $biblionumber );

For multiple holds on a given record for a given patron, the max
number of record level holds that a patron can be placed is the highest
value of the holds_per_record rule for each item if the record for that
patron. This subroutine finds and returns the highest holds_per_record
rule value for a given patron id and record id.

=cut

sub GetMaxPatronHoldsForRecord {
    my ( $borrowernumber, $biblionumber ) = @_;

    my $patron = Koha::Patrons->find($borrowernumber);
    my @items  = Koha::Items->search( { biblionumber => $biblionumber } )->as_list;

    my $controlbranch = C4::Context->preference('ReservesControlBranch');

    my $categorycode = $patron->categorycode;
    my $branchcode;
    $branchcode = $patron->branchcode if ( $controlbranch eq "PatronLibrary" );

    my $max = 0;
    foreach my $item (@items) {
        my $itemtype = $item->effective_itemtype();

        $branchcode = $item->homebranch if ( $controlbranch eq "ItemHomeLibrary" );

        my $rule = Koha::CirculationRules->get_effective_rule(
            {
                categorycode => $categorycode,
                itemtype     => $itemtype,
                branchcode   => $branchcode,
                rule_name    => 'holds_per_record'
            }
        );
        my $holds_per_record = $rule ? $rule->rule_value : 0;
        $max = $holds_per_record if $holds_per_record > $max;
    }

    return $max;
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

1;
