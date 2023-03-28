#!/usr/bin/perl

# Copyright Katipo Communications 2002
# Copyright Koha Development team 2012
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
use C4::Auth qw( get_template_and_user );
use C4::Koha qw( getitemtypeimagelocation getitemtypeimagesrc );
use C4::Circulation qw( GetBranchItemRule GetTransfers );
use C4::Reserves qw( CanItemBeReserved CanBookBeReserved AddReserve GetReservesControlBranch ItemsAnyAvailableAndNotRestricted IsAvailableForItemLevelRequest );
use C4::Biblio qw( GetBiblioData GetFrameworkCode GetMarcBiblio );
use C4::Items qw( GetHostItemsInfo GetItemsInfo );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Members;
use C4::Overdues;

use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::CirculationRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Checkouts;
use Koha::Libraries;
use Koha::Patrons;
use List::MoreUtils qw( uniq );

my $maxreserves = C4::Context->preference("maxreserves");

my $query = CGI->new;

# if OPACHoldRequests (for placing holds) is disabled, leave immediately
if ( ! C4::Context->preference('OPACHoldRequests') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reserve.tt",
        query           => $query,
        type            => "opac",
    }
);

my ($show_holds_count, $show_priority);
for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
    m/holds/o and $show_holds_count = 1;
    m/priority/ and $show_priority = 1;
}

my $patron = Koha::Patrons->find( $borrowernumber, { prefetch => ['categorycode'] } );
my $category = $patron->category;

my $can_place_hold_if_available_at_pickup = C4::Context->preference('OPACHoldsIfAvailableAtPickup');
unless ( $can_place_hold_if_available_at_pickup ) {
    my @patron_categories = split ',', C4::Context->preference('OPACHoldsIfAvailableAtPickupExceptions');
    if ( @patron_categories ) {
        my $categorycode = $patron->categorycode;
        $can_place_hold_if_available_at_pickup = grep { $_ eq $categorycode } @patron_categories;
    }
}

# check if this user can place a reserve, -1 means use sys pref, 0 means dont block, 1 means block
if ( $category->effective_BlockExpiredPatronOpacActions ) {

    if ( $patron->is_expired ) {

        # cannot reserve, their card has expired and the rules set mean this is not allowed
        $template->param( message => 1, expired_patron => 1 );
        output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
        exit;
    }
}

# Pass through any reserve charge
my $reservefee = $category->reservefee;
if ( $reservefee > 0){
    $template->param( RESERVE_CHARGE => $reservefee);
}

my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };

# There are two ways of calling this script, with a single biblio num
# or multiple biblio nums.
my $biblionumbers = $query->param('biblionumbers');
my $reserveMode = $query->param('reserve_mode');
if ($reserveMode && ($reserveMode eq 'single')) {
    my $bib = $query->param('single_bib');
    $biblionumbers = "$bib/";
}
if (! $biblionumbers) {
    $biblionumbers = $query->param('biblionumber');
}

if ((! $biblionumbers) && (! $query->param('place_reserve'))) {
    $template->param(message=>1, no_biblionumber=>1);
    output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
    exit;
}

# Pass the numbers to the page so they can be fed back
# when the hold is confirmed. TODO: Not necessary?
$template->param( biblionumbers => $biblionumbers );

# Each biblio number is suffixed with '/', e.g. "1/2/3/"
my @biblionumbers = split /\//, $biblionumbers;
if (($#biblionumbers < 0) && (! $query->param('place_reserve'))) {
    # TODO: New message?
    $template->param(message=>1, no_biblionumber=>1);
    output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
    exit;
}


# pass the pickup branch along....
my $branch = $query->param('branch') || $patron->branchcode || C4::Context->userenv->{branch} || '' ;
$template->param( branch => $branch );

#
#
# Build hashes of the requested biblio(item)s and items.
#
#

my %biblioDataHash; # Hash of biblionumber to biblio/biblioitems record.
my %itemInfoHash; # Hash of itemnumber to item info.
foreach my $biblioNumber (@biblionumbers) {

    my $biblioData = GetBiblioData($biblioNumber);
    $biblioDataHash{$biblioNumber} = $biblioData;

    my @itemInfos = GetItemsInfo($biblioNumber);

    my $marcrecord= GetMarcBiblio({ biblionumber => $biblioNumber });

    # flag indicating existence of at least one item linked via a host record
    # adding items linked via host biblios
    my @hostitemInfos = GetHostItemsInfo($marcrecord);
    if (@hostitemInfos){
        push (@itemInfos,@hostitemInfos);
    }

    $biblioData->{itemInfos} = \@itemInfos;
    foreach my $itemInfo (@itemInfos) {
        $itemInfoHash{$itemInfo->{itemnumber}} = $itemInfo;
    }

    # Compute the priority rank.
    my $biblio = Koha::Biblios->find( $biblioNumber );
    next unless $biblio;

    $biblioData->{object} = $biblio;
    my $holds = $biblio->holds;
    my $rank = $holds->count;
    $biblioData->{reservecount} = 1;    # new reserve
    while ( my $hold = $holds->next ) {
        if ( $hold->is_waiting ) {
            $rank--;
        }
        else {
            $biblioData->{reservecount}++;
        }
    }
    $biblioData->{rank} = $rank + 1;
}

#
#
# If this is the second time through this script, it
# means we are carrying out the hold request, possibly
# with a specific item for each biblionumber.
#
#
if ( $query->param('place_reserve') ) {
    my $reserve_cnt = 0;
    if ($maxreserves) {
        $reserve_cnt = $patron->holds->count;
    }

    # List is composed of alternating biblio/item/branch
    my $selectedItems = $query->param('selecteditems');

    if ($query->param('reserve_mode') eq 'single') {
        # This indicates non-JavaScript mode, so there was
        # only a single biblio number selected.
        my $bib = $query->param('single_bib');
        my $item = $query->param("checkitem_$bib");
        if ($item eq 'any') {
            $item = '';
        }
        my $branch = $query->param('branch');
        $selectedItems = "$bib/$item/$branch/";
    }

    $selectedItems =~ s!/$!!;
    my @selectedItems = split /\//, $selectedItems, -1;

    # Make sure there is a biblionum/itemnum/branch triplet for each item.
    # The itemnum can be 'any', meaning next available.
    my $selectionCount = @selectedItems;
    if (($selectionCount == 0) || (($selectionCount % 3) != 0)) {
        $template->param(message=>1, bad_data=>1);
        output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
        exit;
    }

    my @failed_holds;
    while (@selectedItems) {
        my $biblioNum = shift(@selectedItems);
        my $itemNum   = shift(@selectedItems);
        my $branch    = shift(@selectedItems);    # i.e., branch code, not name

        my $canreserve = 0;

        my $singleBranchMode = Koha::Libraries->search->count == 1;
        if ( $singleBranchMode || ! C4::Context->preference("OPACAllowUserToChooseBranch") )
        {    # single branch mode or disabled user choosing
            $branch = $patron->branchcode;
        }

        my $item = $itemNum ? Koha::Items->find( $itemNum ) : undef;
        # When choosing a specific item, the default pickup library should be dictated by the default hold policy
        if ( ! C4::Context->preference("OPACAllowUserToChooseBranch") && $item ) {
            my $type = $item->effective_itemtype;
            my $rule = GetBranchItemRule( $patron->branchcode, $type );

            if ( $rule->{hold_fulfillment_policy} eq 'any' || $rule->{hold_fulfillment_policy} eq 'patrongroup' ) {
                $branch = $patron->branchcode;
            } elsif ( $rule->{hold_fulfillment_policy} eq 'holdgroup' ){
                $branch = $item->homebranch;
            } else {
                my $policy = $rule->{hold_fulfillment_policy};
                $branch = $item->$policy;
            }
        }

#item may belong to a host biblio, if yes change biblioNum to hosts bilbionumber
        if ( $item ) {
            my $hostbiblioNum = $item->biblio->biblionumber;
            if ( $hostbiblioNum ne $biblioNum ) {
                $biblioNum = $hostbiblioNum;
            }
        }

        my $biblioData = $biblioDataHash{$biblioNum};
        my $found;

        # Check for user supplied reserve date
        my $startdate;
        if (   C4::Context->preference('AllowHoldDateInFuture')
            && C4::Context->preference('OPACAllowHoldDateInFuture') )
        {
            $startdate = $query->param("reserve_date_$biblioNum");
        }

        my $patron_expiration_date = $query->param("expiration_date_$biblioNum");

        my $itemtype = $query->param('itemtype') || undef;
        $itemtype = undef if $itemNum;

        my $rank = $biblioData->{rank};
        my $patron = Koha::Patrons->find( $borrowernumber );
        if ( $item ) {
            my $status = CanItemBeReserved( $patron, $item, $branch )->{status};
            if( $status eq 'OK' ){
                $canreserve = 1;
            } else {
                push @failed_holds, $status;
            }

        }
        else {
            my $status = CanBookBeReserved( $borrowernumber, $biblioNum, $branch, { itemtype => $itemtype } )->{status};
            if( $status eq 'OK'){
                $canreserve = 1;
            } else {
                push @failed_holds, $status;
            }

            # Inserts a null into the 'itemnumber' field of 'reserves' table.
            $itemNum = undef;
        }
        my $notes = $query->param('notes_'.$biblioNum)||'';

        if (   $maxreserves
            && $reserve_cnt >= $maxreserves )
        {
            push @failed_holds, 'tooManyReserves';
            $canreserve = 0;
        }

        unless ( $can_place_hold_if_available_at_pickup ) {
            my $items_in_this_library = Koha::Items->search({ biblionumber => $biblioNum, holdingbranch => $branch });
            my $nb_of_items_issued = $items_in_this_library->search({ 'issue.itemnumber' => { not => undef }}, { join => 'issue' })->count;
            my $nb_of_items_unavailable = $items_in_this_library->search({ -or => { lost => { '!=' => 0 }, damaged => { '!=' => 0 }, } });
            if ( $items_in_this_library->count > $nb_of_items_issued + $nb_of_items_unavailable ) {
                $canreserve = 0;
                push @failed_holds, 'items_available';
            }
        }

        # Here we actually do the reserveration. Stage 3.
        if ($canreserve) {
            my $reserve_id = AddReserve(
                {
                    branchcode       => $branch,
                    borrowernumber   => $borrowernumber,
                    biblionumber     => $biblioNum,
                    priority         => $rank,
                    reservation_date => $startdate,
                    expiration_date  => $patron_expiration_date,
                    notes            => $notes,
                    title            => $biblioData->{title},
                    itemnumber       => $itemNum,
                    found            => $found,
                    itemtype         => $itemtype,
                }
            );
            if( $reserve_id ){
                ++$reserve_cnt;
            } else {
                push @failed_holds, 'not_placed';
            }
        }
    }

    print $query->redirect("/cgi-bin/koha/opac-user.pl?" . ( @failed_holds ? "failed_holds=" . join('|',@failed_holds) : q|| ) . "#opac-user-holds");
    exit;
}

#
#
# Here we check that the borrower can actually make reserves Stage 1.
#
#
my $noreserves     = 0;
my $maxoutstanding = C4::Context->preference("maxoutstanding");
$template->param( noreserve => 1 ) unless $maxoutstanding;
my $amountoutstanding = $patron->account->balance;
if ( $amountoutstanding && ($amountoutstanding > $maxoutstanding) ) {
    my $amount = sprintf "%.02f", $amountoutstanding;
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_much_oweing => $amount );
}

if ( $patron->gonenoaddress && ($patron->gonenoaddress == 1) ) {
    $noreserves = 1;
    $template->param(
        message => 1,
        GNA     => 1
    );
}

if ( $patron->lost && ($patron->lost == 1) ) {
    $noreserves = 1;
    $template->param(
        message => 1,
        lost    => 1
    );
}

if ( $patron->is_debarred ) {
    $noreserves = 1;
    $template->param(
        message          => 1,
        debarred         => 1,
        debarred_comment => $patron->debarredcomment,
        debarred_date    => $patron->debarred,
    );
}

my $holds = $patron->holds;
my $reserves_count = $holds->count;
$template->param( RESERVES => $holds->unblessed );
if ( $maxreserves && ( $reserves_count >= $maxreserves ) ) {
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_many_reserves => $holds->count );
}

unless ( $noreserves ) {
    my $requested_reserves_count = scalar( @biblionumbers );
    if ( $maxreserves && ( $reserves_count + $requested_reserves_count > $maxreserves ) ) {
        $template->param( new_reserves_allowed => $maxreserves - $reserves_count );
    }
}

unless ($noreserves) {
    $template->param( select_item_types => 1 );
}


#
#
# Build the template parameters that will show the info
# and items for each biblionumber.
#
#

my $biblioLoop = [];
my $numBibsAvailable = 0;
my $itemdata_enumchron = 0;
my $itemdata_ccode = 0;
my $anyholdable = 0;
my $itemLevelTypes = C4::Context->preference('item-level_itypes');
my $pickup_locations = Koha::Libraries->search({ pickup_location => 1 });
$template->param('item_level_itypes' => $itemLevelTypes);

foreach my $biblioNum (@biblionumbers) {

    # Init the bib item with the choices for branch pickup
    my %biblioLoopIter;

    # Get relevant biblio data.
    my $biblioData = $biblioDataHash{$biblioNum};
    if (! $biblioData) {
        $template->param(message=>1, bad_biblionumber=>$biblioNum);
        output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
        exit;
    }

    my @not_available_at = ();
    my $biblio = $biblioData->{object};
    foreach my $library ( $pickup_locations->as_list ) {
        push( @not_available_at, $library->branchcode ) unless $biblio->can_be_transferred({ to => $library });
    }

    my $frameworkcode = GetFrameworkCode( $biblioData->{biblionumber} );
    $biblioLoopIter{biblionumber} = $biblioData->{biblionumber};
    $biblioLoopIter{title} = $biblioData->{title};
    $biblioLoopIter{subtitle} = $biblioData->{'subtitle'};
    $biblioLoopIter{medium} = $biblioData->{medium};
    $biblioLoopIter{part_number} = $biblioData->{part_number};
    $biblioLoopIter{part_name} = $biblioData->{part_name};
    $biblioLoopIter{author} = $biblioData->{author};
    $biblioLoopIter{rank} = $biblioData->{rank};
    $biblioLoopIter{reservecount} = $biblioData->{reservecount};
    $biblioLoopIter{already_reserved} = $biblioData->{already_reserved};
    $biblioLoopIter{reqholdnotes}=0; #TODO: For future use

    if (!$itemLevelTypes && $biblioData->{itemtype}) {
        $biblioLoopIter{translated_description} = $itemtypes->{$biblioData->{itemtype}}{translated_description};
        $biblioLoopIter{imageurl} = getitemtypeimagesrc() . "/". $itemtypes->{$biblioData->{itemtype}}{imageurl};
    }

    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        if ($itemLevelTypes && $itemInfo->{itype}) {
            $itemInfo->{translated_description} = $itemtypes->{$itemInfo->{itype}}{translated_description};
            $itemInfo->{imageurl} = getitemtypeimagesrc() . "/". $itemtypes->{$itemInfo->{itype}}{imageurl};
        }

        if (!$itemInfo->{'notforloan'} && !($itemInfo->{'itemnotforloan'} > 0)) {
            $biblioLoopIter{forloan} = 1;
        }
    }

    my @notforloan_avs = Koha::AuthorisedValues->search_by_koha_field({ kohafield => 'items.notforloan', frameworkcode => $frameworkcode })->as_list;
    my $notforloan_label_of = { map { $_->authorised_value => $_->opac_description } @notforloan_avs };

    my $visible_items = { map { $_->itemnumber => $_ } $biblio->items->filter_by_visible_in_opac( { patron => $patron } )->as_list };

    # Only keep the items that are visible in the opac (i.e. those in %visible_items)
    # FIXME: We should get rid of itemInfos altogether and use $visible_items
    $biblioData->{itemInfos} = [ grep { $visible_items->{ $_->{itemnumber} } } @{ $biblioData->{itemInfos} } ];

    $biblioLoopIter{itemLoop} = [];
    my $numCopiesAvailable = 0;
    my $numCopiesOPACAvailable = 0;
    # iterating through all items first to check if any of them available
    # to pass this value further inside down to IsAvailableForItemLevelRequest to
    # it's complicated logic to analyse.
    # (before this loop was inside that sub loop so it was O(n^2) )
    my $items_any_available;
    $items_any_available = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblioNum, patron => $patron }) if $patron;
    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        my $itemNum = $itemInfo->{itemnumber};
        my $item = $visible_items->{$itemNum};
        my $itemLoopIter = {};

        $itemLoopIter->{itemnumber} = $itemNum;
        $itemLoopIter->{barcode} = $itemInfo->{barcode};
        $itemLoopIter->{homeBranchName} = $itemInfo->{homebranch};
        $itemLoopIter->{callNumber} = $itemInfo->{itemcallnumber};
        $itemLoopIter->{enumchron} = $itemInfo->{enumchron};
        $itemLoopIter->{ccode} = $itemInfo->{ccode};
        $itemLoopIter->{copynumber} = $itemInfo->{copynumber};
        $itemLoopIter->{itemnotes} = $itemInfo->{itemnotes};
        if ($itemLevelTypes) {
            $itemLoopIter->{translated_description} = $itemInfo->{translated_description};
            $itemLoopIter->{itype} = $itemInfo->{itype};
            $itemLoopIter->{imageurl} = $itemInfo->{imageurl};
        }

        # If the holdingbranch is different than the homebranch, we show the
        # holdingbranch of the document too.
        if ( $itemInfo->{homebranch} ne $itemInfo->{holdingbranch} ) {
            $itemLoopIter->{holdingBranchName} = $itemInfo->{holdingbranch};
        }

        # If the item is currently on loan, we display its return date and
        # change the background color.
        my $issue = Koha::Checkouts->find( { itemnumber => $itemNum } );
        if ( $issue ) {
            $itemLoopIter->{dateDue} = $issue->date_due;
            $itemLoopIter->{onloan} = 'onloan';
        }

        # checking reserve
        my $holds = $item->current_holds;

        if ( my $first_hold = $holds->next ) {
            $itemLoopIter->{backgroundcolor} = 'reserved';
            $itemLoopIter->{reservedate}     = $first_hold->reservedate;
            $itemLoopIter->{ExpectedAtLibrary}         = $first_hold->branchcode;
            $itemLoopIter->{waitingdate} = $first_hold->waitingdate;
        }

        $itemLoopIter->{notforloan} = $itemInfo->{notforloan};
        $itemLoopIter->{itemnotforloan} = $itemInfo->{itemnotforloan};

        # Management of the notforloan document
        if ( $itemLoopIter->{notforloan} || $itemLoopIter->{itemnotforloan}) {
            $itemLoopIter->{backgroundcolor} = 'other';
            $itemLoopIter->{notforloanvalue} =
              $notforloan_label_of->{ $itemLoopIter->{notforloan} };
        }

        # Management of lost or long overdue items
        if ( $itemInfo->{itemlost} ) {

            # FIXME localized strings should never be in Perl code
            $itemLoopIter->{message} =
                $itemInfo->{itemlost} == 1 ? "(lost)"
              : $itemInfo->{itemlost} == 2 ? "(long overdue)"
              : "";
            $itemInfo->{backgroundcolor} = 'other';
        }

        # Check of the transferred documents
        my ( $transfertwhen, $transfertfrom, $transfertto ) =
          GetTransfers($itemNum);
        if ( $transfertwhen && ($transfertwhen ne '') ) {
            $itemLoopIter->{transfertwhen} = output_pref({ dt => dt_from_string($transfertwhen), dateonly => 1 });
            $itemLoopIter->{transfertfrom} = $transfertfrom;
            $itemLoopIter->{transfertto} = $transfertto;
            $itemLoopIter->{nocancel} = 1;
        }

        # if the items belongs to a host record, show link to host record
        if ( $itemInfo->{biblionumber} ne $biblioNum ) {
            $itemLoopIter->{hostbiblionumber} = $itemInfo->{biblionumber};
            $itemLoopIter->{hosttitle}        = Koha::Biblios->find( $itemInfo->{biblionumber} )->title;
        }

        # If there is no loan, return and transfer, we show a checkbox.
        $itemLoopIter->{notforloan} = $itemLoopIter->{notforloan} || 0;

        my $patron_unblessed = $patron->unblessed;
        my $branch = GetReservesControlBranch( $itemInfo, $patron_unblessed );

        my $policy_holdallowed = !$itemLoopIter->{already_reserved};
        # items_any_available defined outside of the current loop,
        # so we avoiding loop inside IsAvailableForItemLevelRequest:
        $policy_holdallowed &&=
            CanItemBeReserved( $patron, $item )->{status} eq 'OK' &&
            IsAvailableForItemLevelRequest($item, $patron, undef, $items_any_available);

        if ($policy_holdallowed) {
            my $opac_hold_policy = Koha::CirculationRules->get_opacitemholds_policy( { item => $item, patron => $patron } );
            if ( $opac_hold_policy ne 'N' ) { # If Y or F
                $itemLoopIter->{available} = 1;
                $numCopiesOPACAvailable++;
                $biblioLoopIter{force_hold} = 1 if $opac_hold_policy eq 'F';
            }
            $numCopiesAvailable++;

            unless ( $can_place_hold_if_available_at_pickup ) {
                my $items_in_this_library = Koha::Items->search({ biblionumber => $itemInfo->{biblionumber}, holdingbranch => $itemInfo->{holdingbranch} });
                my $nb_of_items_issued = $items_in_this_library->search({ 'issue.itemnumber' => { not => undef }}, { join => 'issue' })->count;
                if ( $items_in_this_library->count > $nb_of_items_issued ) {
                    push @not_available_at, $itemInfo->{holdingbranch};
                }
            }
        }

        $itemLoopIter->{imageurl} = getitemtypeimagelocation( 'opac', $itemtypes->{ $itemInfo->{itype} }{imageurl} );

    # Show serial enumeration when needed
        if ($itemLoopIter->{enumchron}) {
            $itemdata_enumchron = 1;
        }
    # Show collection when needed
        if ($itemLoopIter->{ccode}) {
            $itemdata_ccode = 1;
        }

        push @{$biblioLoopIter{itemLoop}}, $itemLoopIter;
    }
    $template->param(
        itemdata_enumchron => $itemdata_enumchron,
        itemdata_ccode     => $itemdata_ccode,
    );

    if ($numCopiesAvailable > 0) {
        $numBibsAvailable++;
        $biblioLoopIter{bib_available} = 1;
        $biblioLoopIter{holdable} = 1;
        $biblioLoopIter{itemholdable} = 1 if $numCopiesOPACAvailable;
    }
    if ($biblioLoopIter{already_reserved}) {
        $biblioLoopIter{holdable} = undef;
        $biblioLoopIter{itemholdable} = undef;
    }
    if ( $biblioLoopIter{holdable} ) {
        @not_available_at = uniq @not_available_at;
        $biblioLoopIter{not_available_at} = \@not_available_at ;
    }

    unless ( $can_place_hold_if_available_at_pickup ) {
        @not_available_at = uniq @not_available_at;
        $biblioLoopIter{not_available_at} = \@not_available_at ;
        # The record is not holdable is not available at any of the libraries
        if ( Koha::Libraries->search->count == @not_available_at ) {
            $biblioLoopIter{holdable} = 0;
        }
    }

    my $status = CanBookBeReserved( $borrowernumber, $biblioNum )->{status};
    $biblioLoopIter{holdable} &&= $status eq 'OK';
    $biblioLoopIter{$status} = 1;

    if ( $biblioLoopIter{holdable} and C4::Context->preference('AllowHoldItemTypeSelection') ) {
        # build the allowed item types loop
        my $rs = $biblio->items->search(
            undef,
            {   select => [ { distinct => 'itype' } ],
                as     => 'item_type'
            }
        );

        my @item_types =
          grep { CanBookBeReserved( $borrowernumber, $biblioNum, $branch, { itemtype => $_ } )->{status} eq 'OK' }
          $rs->get_column('item_type');

        $biblioLoopIter{allowed_item_types} = \@item_types;
    }

    if ( $status eq 'recall' ) {
        $biblioLoopIter{recall} = 1;
    }

    # For multiple holds per record, if a patron has previously placed a hold,
    # the patron can only place more holds of the same type. That is, if the
    # patron placed a record level hold, all the holds the patron places must
    # be record level. If the patron placed an item level hold, all holds
    # the patron places must be item level
    my $forced_hold_level = Koha::Holds->search(
        {
            borrowernumber => $borrowernumber,
            biblionumber   => $biblioNum,
            found          => undef,
        }
    )->forced_hold_level();
    if ($forced_hold_level) {
        $biblioLoopIter{force_hold}   = 1 if $forced_hold_level eq 'item';
        $biblioLoopIter{itemholdable} = 0 if $forced_hold_level eq 'record';
        $biblioLoopIter{forced_hold_level} = $forced_hold_level;
    }


    push @$biblioLoop, \%biblioLoopIter;

    $anyholdable = 1 if $biblioLoopIter{holdable};
}

unless ($pickup_locations->count) {
    $numBibsAvailable = 0;
    $anyholdable = 0;
    $template->param(
        message => 1,
        no_pickup_locations => 1
    );
}

if ( $numBibsAvailable == 0 || $anyholdable == 0) {
    $template->param( none_available => 1 );
}

if (scalar @biblionumbers > 1) {
    $template->param( multi_hold => 1);
}

my $show_notes=C4::Context->preference('OpacHoldNotes');
$template->param(OpacHoldNotes=>$show_notes);

# display infos
$template->param(bibitemloop => $biblioLoop);
# can set reserve date in future
if (
    C4::Context->preference( 'AllowHoldDateInFuture' ) &&
    C4::Context->preference( 'OPACAllowHoldDateInFuture' )
    ) {
    $template->param(
	    reserve_in_future         => 1,
    );
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
