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

use strict;
use warnings;
use CGI;
use C4::Auth;    # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Context;
use C4::Members;
use C4::Branch; # GetBranches
use C4::Overdues;
use C4::Debug;
use Koha::DateUtils;
use Koha::Borrower::Debarments qw(IsDebarred);
use Date::Calc qw/Today Date_to_Days/;
# use Data::Dumper;

my $maxreserves = C4::Context->preference("maxreserves");

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reserve.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
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

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

# check if this user can place a reserve, -1 means use sys pref, 0 means dont block, 1 means block
if ( $borr->{'BlockExpiredPatronOpacActions'} ) {

    if ( $borr->{'is_expired'} ) {

        # cannot reserve, their card has expired and the rules set mean this is not allowed
        $template->param( message => 1, expired_patron => 1 );
        get_out( $query, $cookie, $template->output );
    }
}

# Pass through any reserve charge
if ($borr->{reservefee} > 0){
    $template->param( RESERVE_CHARGE => sprintf("%.2f",$borr->{reservefee}));
}
# get branches and itemtypes
my $branches = GetBranches();
my $itemTypes = GetItemTypes();

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
my $branch = $query->param('branch') || $borr->{'branchcode'} || C4::Context->userenv->{branch} || '' ;
($branches->{$branch}) or $branch = "";     # Confirm branch is real
$template->param( branch => $branch );

# make branch selection options...
my $branchloop = GetBranchesLoop($branch);

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

    my $marcrecord= GetMarcBiblio($biblioNumber);

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
    my $reserves = GetReservesFromBiblionumber({ biblionumber => $biblioNumber, all_dates => 1 });
    my $rank = scalar( @$reserves );
    $biblioData->{reservecount} = 1;    # new reserve
    foreach my $res (@{$reserves}) {
        my $found = $res->{found};
        if ( $found && $found eq 'W' ) {
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
        $reserve_cnt = GetReservesFromBorrowernumber( $borrowernumber );
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

    while (@selectedItems) {
        my $biblioNum = shift(@selectedItems);
        my $itemNum   = shift(@selectedItems);
        my $branch    = shift(@selectedItems);    # i.e., branch code, not name

        my $canreserve = 0;

        my $singleBranchMode = C4::Context->preference("singleBranchMode");
        if ( $singleBranchMode || !$OPACChooseBranch )
        {    # single branch mode or disabled user choosing
            $branch = $borr->{'branchcode'};
        }

#item may belong to a host biblio, if yes change biblioNum to hosts bilbionumber
        if ( $itemNum ne '' ) {
            my $hostbiblioNum = GetBiblionumberFromItemnumber($itemNum);
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

        # Here we actually do the reserveration. Stage 3.
        if ($canreserve) {
            AddReserve(
                $branch,      $borrowernumber,
                $biblioNum,   'a',
                [$biblioNum], $rank,
                $startdate,   $expiration_date,
                $notes,       $biblioData->{title},
                $itemNum,     $found
            );
            ++$reserve_cnt;
        }
    }

    print $query->redirect("/cgi-bin/koha/opac-user.pl#opac-user-holds");
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
if ( $borr->{'amountoutstanding'} && ($borr->{'amountoutstanding'} > $maxoutstanding) ) {
    my $amount = sprintf "%.02f", $borr->{'amountoutstanding'};
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_much_oweing => $amount );
}
if ( $borr->{gonenoaddress} && ($borr->{gonenoaddress} == 1) ) {
    $noreserves = 1;
    $template->param(
        message => 1,
        GNA     => 1
    );
}
if ( $borr->{lost} && ($borr->{lost} == 1) ) {
    $noreserves = 1;
    $template->param(
        message => 1,
        lost    => 1
    );
}
if ( IsDebarred($borrowernumber) ) {
    $noreserves = 1;
    $template->param(
        message  => 1,
        debarred => 1
    );
}

my @reserves = GetReservesFromBorrowernumber( $borrowernumber );
my $reserves_count = scalar(@reserves);
$template->param( RESERVES => \@reserves );
if ( $maxreserves && ( $reserves_count >= $maxreserves ) ) {
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_many_reserves => scalar(@reserves));
}

unless ( $noreserves ) {
    my $requested_reserves_count = scalar( @biblionumbers );
    if ( $maxreserves && ( $reserves_count + $requested_reserves_count > $maxreserves ) ) {
        $template->param( new_reserves_allowed => $maxreserves - $reserves_count );
    }
}

foreach my $res (@reserves) {
    foreach my $biblionumber (@biblionumbers) {
        if ( $res->{'biblionumber'} == $biblionumber && $res->{'borrowernumber'} == $borrowernumber) {
#            $template->param( message => 1 );
#            $noreserves = 1;
#            $template->param( already_reserved => 1 );
            $biblioDataHash{$biblionumber}->{already_reserved} = 1;
        }
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
my $notforloan_label_of = get_notforloan_label_of();

my $biblioLoop = [];
my $numBibsAvailable = 0;
my $itemdata_enumchron = 0;
my $anyholdable = 0;
my $itemLevelTypes = C4::Context->preference('item-level_itypes');
$template->param('item_level_itypes' => $itemLevelTypes);

foreach my $biblioNum (@biblionumbers) {

    my $record = GetMarcBiblio($biblioNum);
    # Init the bib item with the choices for branch pickup
    my %biblioLoopIter = ( branchloop => $branchloop );

    # Get relevant biblio data.
    my $biblioData = $biblioDataHash{$biblioNum};
    if (! $biblioData) {
        $template->param(message=>1, bad_biblionumber=>$biblioNum);
        &get_out($query, $cookie, $template->output);
    }

    $biblioLoopIter{biblionumber} = $biblioData->{biblionumber};
    $biblioLoopIter{title} = $biblioData->{title};
    $biblioLoopIter{subtitle} = GetRecordValue('subtitle', $record, GetFrameworkCode($biblioData->{biblionumber}));
    $biblioLoopIter{author} = $biblioData->{author};
    $biblioLoopIter{rank} = $biblioData->{rank};
    $biblioLoopIter{reservecount} = $biblioData->{reservecount};
    $biblioLoopIter{already_reserved} = $biblioData->{already_reserved};
    $biblioLoopIter{mandatorynotes}=0; #FIXME: For future use

    if (!$itemLevelTypes && $biblioData->{itemtype}) {
        $biblioLoopIter{description} = $itemTypes->{$biblioData->{itemtype}}{description};
        $biblioLoopIter{imageurl} = getitemtypeimagesrc() . "/". $itemTypes->{$biblioData->{itemtype}}{imageurl};
    }

    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        $debug and warn $itemInfo->{'notforloan'};

        # Get reserve fee.
        my $fee = GetReserveFee(undef, $borrowernumber, $itemInfo->{'biblionumber'}, 'a',
                                ( $itemInfo->{'biblioitemnumber'} ) );
        $itemInfo->{'reservefee'} = sprintf "%.02f", ($fee ? $fee : 0.0);

        if ($itemLevelTypes && $itemInfo->{itype}) {
            $itemInfo->{description} = $itemTypes->{$itemInfo->{itype}}{description};
            $itemInfo->{imageurl} = getitemtypeimagesrc() . "/". $itemTypes->{$itemInfo->{itype}}{imageurl};
        }

        if (!$itemInfo->{'notforloan'} && !($itemInfo->{'itemnotforloan'} > 0)) {
            $biblioLoopIter{forloan} = 1;
        }
    }

    $biblioLoopIter{itemLoop} = [];
    my $numCopiesAvailable = 0;
    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        my $itemNum = $itemInfo->{itemnumber};
        my $itemLoopIter = {};

        $itemLoopIter->{itemnumber} = $itemNum;
        $itemLoopIter->{barcode} = $itemInfo->{barcode};
        $itemLoopIter->{homeBranchName} = $branches->{$itemInfo->{homebranch}}{branchname};
        $itemLoopIter->{callNumber} = $itemInfo->{itemcallnumber};
        $itemLoopIter->{enumchron} = $itemInfo->{enumchron};
        $itemLoopIter->{copynumber} = $itemInfo->{copynumber};
        if ($itemLevelTypes) {
            $itemLoopIter->{description} = $itemInfo->{description};
            $itemLoopIter->{imageurl} = $itemInfo->{imageurl};
        }

        # If the holdingbranch is different than the homebranch, we show the
        # holdingbranch of the document too.
        if ( $itemInfo->{homebranch} ne $itemInfo->{holdingbranch} ) {
            $itemLoopIter->{holdingBranchName} =
              $branches->{ $itemInfo->{holdingbranch} }{branchname};
        }

        # If the item is currently on loan, we display its return date and
        # change the background color.
        my $issues= GetItemIssue($itemNum);
        if ( $issues->{'date_due'} ) {
            $itemLoopIter->{dateDue} = output_pref({ dt => dt_from_string($issues->{date_due}, 'sql'), as_due_date => 1 });
            $itemLoopIter->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my ($reservedate,$reservedfor,$expectedAt,undef,$wait) = GetReservesFromItemnumber($itemNum);
        my $ItemBorrowerReserveInfo = GetMemberDetails( $reservedfor, 0);

        # the item could be reserved for this borrower vi a host record, flag this
        if ($reservedfor eq $borrowernumber){
            $itemLoopIter->{already_reserved} = 1;
        }

        if ( defined $reservedate ) {
            $itemLoopIter->{backgroundcolor} = 'reserved';
            $itemLoopIter->{reservedate}     = format_date($reservedate);
            $itemLoopIter->{ReservedForBorrowernumber} = $reservedfor;
            $itemLoopIter->{ReservedForSurname}        = $ItemBorrowerReserveInfo->{'surname'};
            $itemLoopIter->{ReservedForFirstname}      = $ItemBorrowerReserveInfo->{'firstname'};
            $itemLoopIter->{ExpectedAtLibrary}         = $expectedAt;
            #waiting status
            $itemLoopIter->{waitingdate} = $wait;
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
            $itemLoopIter->{transfertwhen} = format_date($transfertwhen);
            $itemLoopIter->{transfertfrom} =
              $branches->{$transfertfrom}{branchname};
            $itemLoopIter->{transfertto} = $branches->{$transfertto}{branchname};
            $itemLoopIter->{nocancel} = 1;
        }

	# if the items belongs to a host record, show link to host record
	if ($itemInfo->{biblionumber} ne $biblioNum){
		$biblioLoopIter{hostitemsflag} = 1;
		$itemLoopIter->{hostbiblionumber} = $itemInfo->{biblionumber};
		$itemLoopIter->{hosttitle} = GetBiblioData($itemInfo->{biblionumber})->{title};
	}

        # If there is no loan, return and transfer, we show a checkbox.
        $itemLoopIter->{notforloan} = $itemLoopIter->{notforloan} || 0;

        my $branch = GetReservesControlBranch( $itemInfo, $borr );

        my $branchitemrule = GetBranchItemRule( $branch, $itemInfo->{'itype'} );
        my $policy_holdallowed = 1;

        if ( $branchitemrule->{'holdallowed'} == 0 ||
                ( $branchitemrule->{'holdallowed'} == 1 && $borr->{'branchcode'} ne $itemInfo->{'homebranch'} ) ) {
            $policy_holdallowed = 0;
        }

        if (IsAvailableForItemLevelRequest($itemNum) and $policy_holdallowed and CanItemBeReserved($borrowernumber,$itemNum) eq 'OK' and ($itemLoopIter->{already_reserved} ne 1)) {
            $itemLoopIter->{available} = 1;
            $numCopiesAvailable++;
        }

        $itemLoopIter->{imageurl} = getitemtypeimagelocation( 'opac', $itemTypes->{ $itemInfo->{itype} }{imageurl} );

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
    }
    if ($biblioLoopIter{already_reserved}) {
        $biblioLoopIter{holdable} = undef;
    }
    my $canReserve = CanBookBeReserved($borrowernumber,$biblioNum);
    unless ($canReserve eq 'OK') {
        $biblioLoopIter{holdable} = undef;
        $biblioLoopIter{ $canReserve } = 1;
    }
    if(not C4::Context->preference('AllowHoldsOnPatronsPossessions') and CheckIfIssuedToPatron($borrowernumber,$biblioNum)) {
        $biblioLoopIter{holdable} = undef;
        $biblioLoopIter{already_patron_possession} = 1;
    }

    if( $biblioLoopIter{holdable} ){ $anyholdable++; }

    push @$biblioLoop, \%biblioLoopIter;
}

if ( $numBibsAvailable == 0 || $anyholdable == 0) {
    $template->param( none_available => 1 );
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

output_html_with_http_headers $query, $cookie, $template->output;

