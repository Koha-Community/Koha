#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
use CGI;
use C4::Biblio;
use C4::Items;
use C4::Auth;    # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Context;
use C4::Members;
use C4::Branch; # GetBranches
use C4::Debug;
# use Data::Dumper;

my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-reserve.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

sub get_out ($$$) {
	output_html_with_http_headers(shift,shift,shift); # $query, $cookie, $template->output;
	exit;
}

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

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
my $branch = $query->param('branch');
$template->param( branch => $branch );

# make sure it's a real branch
if ( !$branch || !$branches->{$branch} ) {
    $branch = '';
}
$template->param( branchname => $branches->{$branch}->{'branchname'} );

# make branch selection options...
my @branches;
my @select_branch;
my %select_branches;

my @CGIbranchlooparray;

foreach my $branch ( keys %$branches ) {
    if ($branch) {
        my %line;
        $line{branch} = $branches->{$branch}->{'branchname'};
        $line{value}  = $branch;
        if ($line{value} eq C4::Context->userenv->{'branch'}) {
            $line{selected} = 1;
        }
        push @CGIbranchlooparray, \%line;
    }
}
@CGIbranchlooparray =
   sort { $a->{branch} cmp $b->{branch} } @CGIbranchlooparray;
my $CGIbranchloop = \@CGIbranchlooparray;
$template->param( CGIbranch => $CGIbranchloop );


#Debug
#output_html_with_http_headers($query,$cookie,"<html><head></head><body> @biblionumbers </body></html>\n");
#exit;
#my %bibdata;
#my $rank;
#my $biblionumber;
#my $bibdata;
#my %itemhash;
#my $forloan;

#
#
# Build hashes of the requested biblio(item)s and items.
#
#

# Hash of biblionumber to biblio/biblioitems record.
my %biblioDataHash;

# Hash of itemnumber to item info.
my %itemInfoHash;

foreach my $biblioNumber (@biblionumbers) {

    my $biblioData = GetBiblioData($biblioNumber);
    $biblioDataHash{$biblioNumber} = $biblioData;

    my @itemInfos = GetItemsInfo($biblioNumber);
    $biblioData->{itemInfos} = \@itemInfos;
    foreach my $itemInfo (@itemInfos) {
        $itemInfoHash{$itemInfo->{itemnumber}} = $itemInfo;
    }

    # Compute the priority rank.
    my ( $rank, $reserves ) = GetReservesFromBiblionumber($biblioNumber);
    $biblioData->{reservecount} = $rank;
    foreach my $res (@$reserves) {
        my $found = $res->{'found'};
        if ( $found && ($found eq 'W') ) {
            $rank--;
        }
    }
    $rank++;
    $biblioData->{rank} = $rank;
}

#
#
# If this is the second time through this script, it
# means we are carrying out the hold request, possibly
# with a specific item for each biblionumber.
#
#
if ( $query->param('place_reserve') ) {

    my $notes = $query->param('notes');

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
    
    my @selectedItems = split /\//, $selectedItems;

    # Make sure there is a biblionum/itemnum/branch triplet for each item.
    # The itemnum can be 'any', meaning next available.
    my $selectionCount = @selectedItems;
    if (($selectionCount == 0) || (($selectionCount % 3) != 0)) {
        $template->param(message=>1, bad_data=>1);
        &get_out($query, $cookie, $template->output);
    }

    while (@selectedItems) {
        my $biblioNum = shift(@selectedItems);
        my $itemNum = shift(@selectedItems);
        my $branch = shift(@selectedItems); # i.e., branch code, not name

        my $singleBranchMode = $template->param('singleBranchMode');
        if ($singleBranchMode) {
            $branch = $borr->{'branchcode'};
        }

        my $biblioData = $biblioDataHash{$biblioNum};
        my $found;
        
        # If a specific item was selected and the pickup branch is the same as the
        # holdingbranch, force the value $rank and $found.
        my $rank = $biblioData->{rank};
        if ($itemNum ne ''){
            $rank = '0' unless C4::Context->preference('ReservesNeedReturns');
            my $item = GetItem($itemNum);
            if ( $item->{'holdingbranch'} eq $branch ){
                $found = 'W' unless C4::Context->preference('ReservesNeedReturns');
            }
        }
        else {
            # Inserts a null into the 'itemnumber' field of 'reserves' table.
            $itemNum = undef;
        }
        
        # Here we actually do the reserveration. Stage 3.
        AddReserve($branch, $borrowernumber, $biblioNum, 'a', [$biblioNum], $rank, $notes,
                   $biblioData->{'title'}, $itemNum, $found);
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
    my $amount = sprintf "\$%.02f", $borr->{'amountoutstanding'};
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_much_oweing => $amount );
}
if ( $borr->{gonenoaddress} && ($borr->{gonenoaddress} eq 1) ) {
    $noreserves = 1;
    $template->param(
                     message => 1,
                     GNA     => 1
                    );
}
if ( $borr->{lost} && ($borr->{lost} eq 1) ) {
    $noreserves = 1;
    $template->param(
                     message => 1,
                     lost    => 1
                    );
}
if ( $borr->{debarred} && ($borr->{debarred} eq 1) ) {
    $noreserves = 1;
    $template->param(
                     message  => 1,
                     debarred => 1
                    );
}

my @reserves = GetReservesFromBorrowernumber( $borrowernumber );
$template->param( RESERVES => \@reserves );
if ( scalar(@reserves) >= $MAXIMUM_NUMBER_OF_RESERVES ) {
    $template->param( message => 1 );
    $noreserves = 1;
    $template->param( too_many_reserves => scalar(@reserves));
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
my $itemLevelTypes = C4::Context->preference('item-level_itypes');
$template->param('item-level_itypes' => $itemLevelTypes);

foreach my $biblioNum (@biblionumbers) {

    my $record = GetMarcBiblio($biblioNum);
    my $subtitle = C4::Biblio::get_koha_field_from_marc('bibliosubtitle', 'subtitle', $record, '');
    # Init the bib item with the choices for branch pickup
    my %biblioLoopIter = ( branchChoicesLoop => $CGIbranchloop );

    # Get relevant biblio data.
    my $biblioData = $biblioDataHash{$biblioNum};
    if (! $biblioData) {
        $template->param(message=>1, bad_biblionumber=>$biblioNum);
	&get_out($query, $cookie, $template->output);
    }

    $biblioLoopIter{biblionumber} = $biblioData->{biblionumber};
    $biblioLoopIter{title} = $biblioData->{title};
    $biblioLoopIter{subtitle} = $subtitle;
    $biblioLoopIter{author} = $biblioData->{author};
    $biblioLoopIter{rank} = $biblioData->{rank};
    $biblioLoopIter{reservecount} = $biblioData->{reservecount};
    $biblioLoopIter{already_reserved} = $biblioData->{already_reserved};

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

    $biblioLoopIter{itemTypeDescription} =
      $itemTypes->{$biblioData->{itemtype}}{description};
    

    $biblioLoopIter{itemLoop} = [];
    my $numCopiesAvailable = 0;
    foreach my $itemInfo (@{$biblioData->{itemInfos}}) {
        my $itemNum = $itemInfo->{itemnumber};
        my $itemLoopIter = {};

        $itemLoopIter->{itemnumber} = $itemNum;
        $itemLoopIter->{barcode} = $itemInfo->{barcode};
        $itemLoopIter->{homeBranchName} = $branches->{$itemInfo->{homebranch}}{branchname};
        $itemLoopIter->{callNumber} = $itemInfo->{itemcallnumber};
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
            $itemLoopIter->{dateDue} = format_date($issues->{'date_due'});
            $itemLoopIter->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my ($reservedate,$reservedfor,$expectedAt) = GetReservesFromItemnumber($itemNum);
        my $ItemBorrowerReserveInfo = GetMemberDetails( $reservedfor, 0);

        if ( defined $reservedate ) {
            $itemLoopIter->{backgroundcolor} = 'reserved';
            $itemLoopIter->{reservedate}     = format_date($reservedate);
            $itemLoopIter->{ReservedForBorrowernumber}     = $reservedfor;
            $itemLoopIter->{ReservedForSurname}     = $ItemBorrowerReserveInfo->{'surname'};
            $itemLoopIter->{ReservedForFirstname}     = $ItemBorrowerReserveInfo->{'firstname'};
            $itemLoopIter->{ExpectedAtLibrary}     = $expectedAt;
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

        # If there is no loan, return and transfer, we show a checkbox.
        $itemLoopIter->{notforloan} = $itemLoopIter->{notforloan} || 0;

        my $branchitemrule = GetBranchItemRule( $borr->{'branchcode'}, $itemInfo->{'itype'} );
        my $policy_holdallowed = 1;

        if ( $branchitemrule->{'holdallowed'} == 0 ||
                ( $branchitemrule->{'holdallowed'} == 1 && $borr->{'branchcode'} ne $itemInfo->{'homebranch'} ) ) {
            $policy_holdallowed = 0;
        }

        if (IsAvailableForItemLevelRequest($itemNum) and $policy_holdallowed) {
            $itemLoopIter->{available} = 1;
            $numCopiesAvailable++;
        }

	# FIXME: move this to a pm
        my $dbh = C4::Context->dbh;
        my $sth2 = $dbh->prepare("SELECT * FROM reserves WHERE borrowernumber=? AND itemnumber=? AND found='W'");
        $sth2->execute($itemLoopIter->{ReservedForBorrowernumber}, $itemNum);
        while (my $wait_hashref = $sth2->fetchrow_hashref) {
            $itemLoopIter->{waitingdate} = format_date($wait_hashref->{waitingdate});
        }
	$itemLoopIter->{imageurl} = getitemtypeimagelocation( 'opac', $itemTypes->{ $itemInfo->{itype} }{imageurl} );

        
        push @{$biblioLoopIter{itemLoop}}, $itemLoopIter;
    }

    if ($numCopiesAvailable > 0) {
        $numBibsAvailable++;
        $biblioLoopIter{bib_available} = 1;
        $biblioLoopIter{holdable} = 1;
    }
    if ($biblioLoopIter{already_reserved}) {
        $biblioLoopIter{holdable} = undef;
    }

    push @$biblioLoop, \%biblioLoopIter;
}


if ( $numBibsAvailable == 0 ) {
    $template->param( none_available => 1, message => 1 );
}


my $itemTableColspan = 5;
if (!$template->param('OPACItemHolds')) {
    $itemTableColspan--;
}
if ($template->param('singleBranchMode')) {
    $itemTableColspan--;
}
$template->param(itemtable_colspan => $itemTableColspan);



# display infos
$template->param(bibitemloop => $biblioLoop);
output_html_with_http_headers $query, $cookie, $template->output;





# Local Variables:
# tab-width: 8
# End:
