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
use C4::Auth;    # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Overdues;
use C4::Debug;

use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::DateUtils;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Checkouts;
use Koha::Libraries;
use Koha::Patrons;
use Date::Calc qw/Today Date_to_Days/;
use List::MoreUtils qw/uniq/;

my $maxreserves = C4::Context->preference("maxreserves");

my $query = new CGI;

# if RequestOnOpac (for placing holds) is disabled, leave immediately
if ( ! C4::Context->preference('RequestOnOpac') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reserve.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my ($show_holds_count, $show_priority);
for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
    m/holds/o and $show_holds_count = 1;
    m/priority/ and $show_priority = 1;
}

sub get_out {
	output_html_with_http_headers(shift,shift,shift); # $query, $cookie, $template->output;
	exit;
}

my $patron = Koha::Patrons->find( $borrowernumber );

my $can_place_hold_if_available_at_pickup = C4::Context->preference('OPACHoldsIfAvailableAtPickup');
unless ( $can_place_hold_if_available_at_pickup ) {
    my @patron_categories = split '\|', C4::Context->preference('OPACHoldsIfAvailableAtPickupExceptions');
    if ( @patron_categories ) {
        my $categorycode = $patron->categorycode;
        $can_place_hold_if_available_at_pickup = grep /^$categorycode$/, @patron_categories;
    }
}

# check if this user can place a reserve, -1 means use sys pref, 0 means dont block, 1 means block
if ( $patron->category->effective_BlockExpiredPatronOpacActions ) {

    if ( $patron->is_expired ) {

        # cannot reserve, their card has expired and the rules set mean this is not allowed
        $template->param( message => 1, expired_patron => 1 );
        get_out( $query, $cookie, $template->output );
    }
}

# Pass through any reserve charge
my $reservefee = $patron->category->reservefee;
if ( $reservefee > 0){
    $template->param( RESERVE_CHARGE => sprintf("%.2f",$reservefee));
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
    &get_out($query, $cookie, $template->output);
}

# Pass the numbers to the page so they can be fed back
# when the hold is confirmed. TODO: Not necessary?
$template->param( biblionumbers => $biblionumbers );

# Each biblio number is suffixed with '/', e.g. "1/2/3/"
my @biblionumbers = split /\//, $biblionumbers;
if (($#biblionumbers < 0) && (! $query->param('place_reserve'))) {
    # TODO: New message?
    $template->param(message=>1, no_biblionumber=>1);
    &get_out($query, $cookie, $template->output);
}


# pass the pickup branch along....
my $branch = $query->param('branch') || $patron->branchcode || C4::Context->userenv->{branch} || '' ;
$template->param( branch => $branch );

# Is the person allowed to choose their branch
my $OPACChooseBranch = (C4::Context->preference("OPACAllowUserToChooseBranch")) ? 1 : 0;

$template->param( choose_branch => $OPACChooseBranch);

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
    my $hostitemsflag;
    # adding items linked via host biblios
    my @hostitemInfos = GetHostItemsInfo($marcrecord);
    if (@hostitemInfos){
        $hostitemsflag =1;
        push (@itemInfos,@hostitemInfos);
    }

    $biblioData->{itemInfos} = \@itemInfos;
    foreach my $itemInfo (@itemInfos) {
        $itemInfoHash{$itemInfo->{itemnumber}} = $itemInfo;
    }

    # Compute the priority rank.
    my $biblio = Koha::Biblios->find( $biblioNumber );
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
        &get_out($query, $cookie, $template->output);
    }

    my $failed_holds = 0;
    while (@selectedItems) {
        my $biblioNum = shift(@selectedItems);
        my $itemNum   = shift(@selectedItems);
        my $branch    = shift(@selectedItems);    # i.e., branch code, not name

        my $canreserve = 0;

        my $singleBranchMode = Koha::Libraries->search->count == 1;
        if ( $singleBranchMode || !$OPACChooseBranch )
        {    # single branch mode or disabled user choosing
            $branch = $patron->branchcode;
        }

#item may belong to a host biblio, if yes change biblioNum to hosts bilbionumber
        if ( $itemNum ne '' ) {
            my $item = Koha::Items->find( $itemNum );
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

        my $expiration_date = $query->param("expiration_date_$biblioNum");

      # If a specific item was selected and the pickup branch is the same as the
      # holdingbranch, force the value $rank and $found.
        my $rank = $biblioData->{rank};
        if ( $itemNum ne '' ) {
            $canreserve = 1 if CanItemBeReserved( $borrowernumber, $itemNum ) eq 'OK';
            $rank = '0' unless C4::Context->preference('ReservesNeedReturns');
            my $item = GetItem($itemNum);
            if ( $item->{'holdingbranch'} eq $branch ) {
                $found = 'W'
                  unless C4::Context->preference('ReservesNeedReturns');
            }
        }
        else {
            $canreserve = 1 if CanBookBeReserved( $borrowernumber, $biblioNum ) eq 'OK';

            # Inserts a null into the 'itemnumber' field of 'reserves' table.
            $itemNum = undef;
        }
        my $notes = $query->param('notes_'.$biblioNum)||'';

        if (   $maxreserves
            && $reserve_cnt >= $maxreserves )
        {
            $canreserve = 0;
        }

        unless ( $can_place_hold_if_available_at_pickup ) {
            my $items_in_this_library = Koha::Items->search({ biblionumber => $biblioNum, holdingbranch => $branch });
            my $nb_of_items_issued = $items_in_this_library->search({ 'issue.itemnumber' => { not => undef }}, { join => 'issue' })->count;
            my $nb_of_items_unavailable = $items_in_this_library->search({ -or => { lost => { '!=' => 0 }, damaged => { '!=' => 0 }, } });
            if ( $items_in_this_library->count > $nb_of_items_issued + $nb_of_items_unavailable ) {
                $canreserve = 0
            }
        }

        my $itemtype = $query->param('itemtype') || undef;
        $itemtype = undef if $itemNum;

        # Here we actually do the reserveration. Stage 3.
        if ($canreserve) {
            my $reserve_id = AddReserve(
                $branch,          $borrowernumber, $biblioNum,
                [$biblioNum],     $rank,           $startdate,
                $expiration_date, $notes,          $biblioData->{title},
                $itemNum,         $found,          $itemtype,
            );
            $failed_holds++ unless $reserve_id;
            ++$reserve_cnt;
        }
    }

    print $query->redirect("/cgi-bin/koha/opac-user.pl?" . ( $failed_holds ? "failed_holds=$failed_holds" : q|| ) . "#opac-user-holds");
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
my $anyholdable = 0;
my $itemLevelTypes = C4::Context->preference('item-level_itypes');
$template->param('item_level_itypes' => $itemLevelTypes);

foreach my $biblioNum (@biblionumbers) {

    my @not_available_at = ();
    my $record = GetMarcBiblio({ biblionumber => $biblioNum });
    # Init the bib item with the choices for branch pickup
    my %biblioLoopIter;

    # Get relevant biblio data.
    my $biblioData = $biblioDataHash{$biblioNum};
    if (! $biblioData) {
        $template->param(message=>1, bad_biblionumber=>$biblioNum);
        &get_out($query, $cookie, $template->output);
    }

    my $frameworkcode = GetFrameworkCode( $biblioData->{biblionumber} );
    $biblioLoopIter{biblionumber} = $biblioData->{biblionumber};
    $biblioLoopIter{title} = $biblioData->{title};
    $biblioLoopIter{subtitle} = GetRecordValue('subtitle', $record, $frameworkcode);
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

    my @notforloan_avs = Koha::AuthorisedValues->search_by_koha_field({ kohafield => 'items.notforloan', frameworkcode => $frameworkcode });
    my $notforloan_label_of = { map { $_->authorised_value => $_->opac_description } @notforloan_avs };

    $biblioLoopIter{itemLoop} = [];
    my $numCopiesAvailable = 0;
    my $numCopiesOPACAvailable = 0;
    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        my $itemNum = $itemInfo->{itemnumber};
        my $item = Koha::Items->find( $itemNum );
        my $itemLoopIter = {};

        $itemLoopIter->{itemnumber} = $itemNum;
        $itemLoopIter->{barcode} = $itemInfo->{barcode};
        $itemLoopIter->{homeBranchName} = $itemInfo->{homebranch};
        $itemLoopIter->{callNumber} = $itemInfo->{itemcallnumber};
        $itemLoopIter->{enumchron} = $itemInfo->{enumchron};
        $itemLoopIter->{copynumber} = $itemInfo->{copynumber};
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
            $itemLoopIter->{dateDue} = output_pref({ dt => dt_from_string($issue->date_due, 'sql'), as_due_date => 1 });
            $itemLoopIter->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my $holds = $item->current_holds;

        if ( my $first_hold = $holds->next ) {
            $itemLoopIter->{backgroundcolor} = 'reserved';
            $itemLoopIter->{reservedate}     = output_pref({ dt => dt_from_string($first_hold->reservedate), dateonly => 1 }); # FIXME Should be formatted in the template
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

        # Check of the transfered documents
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
            $biblioLoopIter{hostitemsflag}    = 1;
            $itemLoopIter->{hostbiblionumber} = $itemInfo->{biblionumber};
            $itemLoopIter->{hosttitle}        = Koha::Biblios->find( $itemInfo->{biblionumber} )->title;
        }

        # If there is no loan, return and transfer, we show a checkbox.
        $itemLoopIter->{notforloan} = $itemLoopIter->{notforloan} || 0;

        my $patron_unblessed = $patron->unblessed;
        my $branch = GetReservesControlBranch( $itemInfo, $patron_unblessed );

        my $policy_holdallowed = !$itemLoopIter->{already_reserved};
        $policy_holdallowed &&=
            IsAvailableForItemLevelRequest($itemInfo,$patron_unblessed) &&
            CanItemBeReserved($borrowernumber,$itemNum) eq 'OK';

        if ($policy_holdallowed) {
            my $opac_hold_policy = Koha::IssuingRules->get_opacitemholds_policy( { item => $item, patron => $patron } );
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

        push @{$biblioLoopIter{itemLoop}}, $itemLoopIter;
    }
    $template->param( itemdata_enumchron => $itemdata_enumchron );

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
    if(not C4::Context->preference('AllowHoldsOnPatronsPossessions') and CheckIfIssuedToPatron($borrowernumber,$biblioNum)) {
        $biblioLoopIter{holdable} = undef;
        $biblioLoopIter{already_patron_possession} = 1;
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

    $biblioLoopIter{holdable} &&= CanBookBeReserved($borrowernumber,$biblioNum) eq 'OK';

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
    }


    push @$biblioLoop, \%biblioLoopIter;

    $anyholdable = 1 if $biblioLoopIter{holdable};
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
