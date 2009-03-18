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
my $itemtypes = GetItemTypes();

# get biblionumber.....
my $biblionumber = $query->param('biblionumber');
if (! $biblionumber) {
	$template->param(message=>1,no_biblionumber=>1);
	&get_out($query, $cookie, $template->output);
}
$template->param( biblionumber => $biblionumber );

my $bibdata = GetBiblioData($biblionumber);
if (! $bibdata) {
	$template->param(message=>1,bad_biblionumber=>$biblionumber);
	&get_out($query, $cookie, $template->output);
}
$template->param($bibdata);		# FIXME: bad form.

# get the rank number....
my ( $rank, $reserves ) = GetReservesFromBiblionumber( $biblionumber);
$template->param( reservecount => $rank );

foreach my $res (@$reserves) {
    if ( $res->{'found'} eq 'W' ) {
        $rank--;
    }
}

$rank++;
$template->param( rank => $rank );

# pass the pickup branch along....
my $branch = $query->param('branch');
$template->param( branch => $branch );

# make sure it's a real branch
if ( !$branches->{$branch} ) {
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
@CGIbranchlooparray = sort { $a->{branch} cmp $b->{branch} } @CGIbranchlooparray;
my $CGIbranchloop = \@CGIbranchlooparray;
$template->param( CGIbranch => $CGIbranchloop );

my @items = GetItemsInfo($biblionumber);

# an item was previously required to have an itemtype in order to be reserved.
# this behavior removed to fix bug 1891 .
# my @items = grep { (C4::Context->preference('item-level_itypes') ? $_->{'itype'} : $_->{'itemtype'} ) } @all_items ;

$template->param( itemcount => scalar(@items) );

my %itemhash;
my $forloan;
foreach my $itm (@items) {
	$debug and warn $itm->{'notforloan'};
    my $fee = GetReserveFee( undef, $borrowernumber, $itm->{'biblionumber'}, 'a', ( $itm->{'biblioitemnumber'} ) );
    $itm->{'reservefee'} = sprintf "%.02f", $fee;
    # pass itype to itemtype for display purposes.  
    $itm->{'itemtype'} = $itm->{'itype'} if(C4::Context->preference('item-level_itypes')); 	
	$itemhash{$itm->{'itemnumber'}}=$itm;
    if (!$itm->{'notforloan'} && !($itm->{'itemnotforloan'} > 0)){
		$forloan=1;
	}
}

if ( $query->param('place_reserve') ) {
    my @bibitems=$query->param('biblioitem');
    my $notes=$query->param('notes');
    my $checkitem=$query->param('checkitem');
    my $found;
    
<<<<<<< HEAD:opac/opac-reserve.pl
    #if we have an item selectionned, and the pickup branch is the same as the holdingbranch of the document, we force the value $rank and $found.
    if ($checkitem ne ''){
        $rank = '0' unless C4::Context->preference('ReservesNeedReturns');
        my $item = $checkitem;
        $item = GetItem($item);
        if ( $item->{'holdingbranch'} eq $branch ){
            $found = 'W' unless C4::Context->preference('ReservesNeedReturns');
=======
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
        my $itemNum   = shift(@selectedItems);
        my $branch    = shift(@selectedItems); # i.e., branch code, not name

        my $singleBranchMode = $template->param('singleBranchMode');
        if ($singleBranchMode) {
            $branch = $borr->{'branchcode'};
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
        }
    }
        
        my $count=@bibitems;
    @bibitems=sort @bibitems;
    my $i2=1;
    my @realbi;
    $realbi[0]=$bibitems[0];
    for (my $i=1;$i<$count;$i++) {
        my $i3=$i2-1;
        if ($realbi[$i3] ne $bibitems[$i]) {
            $realbi[$i2]=$bibitems[$i];
            $i2++;
        }
    }
    # here we actually do the reserveration. Stage 3.
    if ($query->param('request') eq 'any'){
        # place a request on 1st available
        AddReserve($branch,$borrowernumber,$biblionumber,'a',\@realbi,$rank,$notes,$bibdata->{'title'},$checkitem,$found);
    } else {
        AddReserve($branch,$borrowernumber,$biblionumber,'a',\@realbi,$rank,$notes,$bibdata->{'title'},$checkitem, $found);
    }
    print $query->redirect("/cgi-bin/koha/opac-user.pl#opac-user-holds");
}
else {

    # Here we check that the borrower can actually make reserves Stage 1.
    my $noreserves     = 0;
    my $maxoutstanding = C4::Context->preference("maxoutstanding");
    $template->param( noreserve => 1 ) unless $maxoutstanding;
    if ( $borr->{'amountoutstanding'} > $maxoutstanding ) {
        my $amount = sprintf "\$%.02f", $borr->{'amountoutstanding'};
        $template->param( message => 1 );
        $noreserves = 1;
        $template->param( too_much_oweing => $amount );
    }
    if ( $borr->{gonenoaddress} eq 1 ) {
        $noreserves = 1;
        $template->param(
            message => 1,
            GNA     => 1
        );
    }
    if ( $borr->{lost} eq 1 ) {
        $noreserves = 1;
        $template->param(
            message => 1,
            lost    => 1
        );
    }
    if ( $borr->{debarred} eq 1 ) {
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
        if ( $res->{'biblionumber'} == $biblionumber && $res->{'borrowernumber'} == $borrowernumber) {
            $template->param( message => 1 );
            $noreserves = 1;
            $template->param( already_reserved => 1 );
        }
    }
    unless ($noreserves) {
        $template->param( select_item_types => 1 );
    }
}


my %itemnumbers_of_biblioitem;
my @itemnumbers  = @{ get_itemnumbers_of($biblionumber)->{$biblionumber} };
my $iteminfos_of = GetItemInfosOf(@itemnumbers);

foreach my $itemnumber (@itemnumbers) {
    my $biblioitemnumber = $iteminfos_of->{$itemnumber}->{biblioitemnumber};
    push( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} }, $itemnumber );
}

my @biblioitemnumbers = keys %itemnumbers_of_biblioitem;

my $notforloan_label_of = get_notforloan_label_of();
my $biblioiteminfos_of  = GetBiblioItemInfosOf(@biblioitemnumbers);

my @itemtypes;
foreach my $biblioitemnumber (@biblioitemnumbers) {
    push @itemtypes, $biblioiteminfos_of->{$biblioitemnumber}{itemtype};
}

my @bibitemloop;

foreach my $biblioitemnumber (@biblioitemnumbers) {
    my $biblioitem = $biblioiteminfos_of->{$biblioitemnumber};

<<<<<<< HEAD:opac/opac-reserve.pl
    $biblioitem->{description} =
      $itemtypes->{ $biblioitem->{itemtype} }{description};
=======
    # Get relevant biblio data.
    my $biblioData = $biblioDataHash{$biblioNum};
    if (! $biblioData) {
        $template->param(message=>1, bad_biblionumber=>$biblioNum);
        &get_out($query, $cookie, $template->output);
    }
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl

    foreach
      my $itemnumber ( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} } )
    {
		my $item = $itemhash{$itemnumber};

        $item->{homebranchname} =
          $branches->{ $item->{homebranch} }{branchname};

        # if the holdingbranch is different than the homebranch, we show the
        # holdingbranch of the document too
        if ( $item->{homebranch} ne $item->{holdingbranch} ) {
            $item->{holdingbranchname} =
              $branches->{ $item->{holdingbranch} }{branchname};
        }
        
<<<<<<< HEAD:opac/opac-reserve.pl
# 	add information
	$item->{itemcallnumber} = $item->{itemcallnumber};
	
        # if the item is currently on loan, we display its return date and
        # change the background color
        my $issues= GetItemIssue($itemnumber);
=======
        if (!$itemInfo->{'notforloan'} && !($itemInfo->{'itemnotforloan'} > 0)) {
            $biblioLoopIter{forloan} = 1;
        }
    }

    $biblioLoopIter{itemTypeDescription} = $itemTypes->{$biblioData->{itemtype}}{description};

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
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
        if ( $issues->{'date_due'} ) {
            $item->{date_due} = format_date($issues->{'date_due'});
            $item->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my ($reservedate,$reservedfor,$expectedAt) = GetReservesFromItemnumber($itemnumber);
        my $ItemBorrowerReserveInfo = GetMemberDetails( $reservedfor, 0);

        if ( defined $reservedate ) {
<<<<<<< HEAD:opac/opac-reserve.pl
            $item->{backgroundcolor} = 'reserved';
            $item->{reservedate}     = format_date($reservedate);
            $item->{ReservedForBorrowernumber}     = $reservedfor;
            $item->{ReservedForSurname}     = $ItemBorrowerReserveInfo->{'surname'};
            $item->{ReservedForFirstname}     = $ItemBorrowerReserveInfo->{'firstname'};
            $item->{ExpectedAtLibrary}     = $expectedAt;
            
=======
            $itemLoopIter->{backgroundcolor} = 'reserved';
            $itemLoopIter->{reservedate}     = format_date($reservedate);
            $itemLoopIter->{ReservedForBorrowernumber} = $reservedfor;
            $itemLoopIter->{ReservedForSurname}        = $ItemBorrowerReserveInfo->{'surname'};
            $itemLoopIter->{ReservedForFirstname}      = $ItemBorrowerReserveInfo->{'firstname'};
            $itemLoopIter->{ExpectedAtLibrary}         = $expectedAt;
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
        }

        # Management of the notforloan document
        if ( $item->{notforloan} || $item->{itemnotforloan}) {
            $item->{backgroundcolor} = 'other';
            $item->{notforloanvalue} =
              $notforloan_label_of->{ $item->{notforloan} };
        }

        # Management of lost or long overdue items
        if ( $item->{itemlost} ) {

            # FIXME localized strings should never be in Perl code
            $item->{message} =
                $item->{itemlost} == 1 ? "(lost)"
              : $item->{itemlost} == 2 ? "(long overdue)"
              : "";
            $item->{backgroundcolor} = 'other';
        }

        # Check of the transfered documents
        my ( $transfertwhen, $transfertfrom, $transfertto ) =
          GetTransfers($itemnumber);

        if ( $transfertwhen ne '' ) {
            $item->{transfertwhen} = format_date($transfertwhen);
            $item->{transfertfrom} =
              $branches->{$transfertfrom}{branchname};
            $item->{transfertto} = $branches->{$transfertto}{branchname};
		$item->{nocancel} = 1;
        }

        # If there is no loan, return and transfer, we show a checkbox.
        $item->{notforloan} = $item->{notforloan} || 0;

        if (IsAvailableForItemLevelRequest($itemnumber)) {
            $item->{available} = 1;
        }

	# FIXME: move this to a pm
        my $dbh = C4::Context->dbh;
        my $sth2 = $dbh->prepare("SELECT * FROM reserves WHERE borrowernumber=? AND itemnumber=? AND found='W'");
        $sth2->execute($item->{ReservedForBorrowernumber},$item->{itemnumber});
        while (my $wait_hashref = $sth2->fetchrow_hashref) {
            $item->{waitingdate} = format_date($wait_hashref->{waitingdate});
        }
<<<<<<< HEAD:opac/opac-reserve.pl
	$item->{imageurl} = getitemtypeimagelocation( 'opac', $itemtypes->{ $item->{itype} }{imageurl} );
        push @{ $biblioitem->{itemloop} }, $item;
=======
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
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
    }

    push @bibitemloop, $biblioitem;
}

<<<<<<< HEAD:opac/opac-reserve.pl
=======
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

>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
# display infos
$template->param(
	forloan           => $forloan,
    bibitemloop       => \@bibitemloop,
);
output_html_with_http_headers $query, $cookie, $template->output;

<<<<<<< HEAD:opac/opac-reserve.pl
# Local Variables:
# tab-width: 8
# End:
=======
>>>>>>> 9f01cc0... whitespace cleanup and remove editor comments:opac/opac-reserve.pl
