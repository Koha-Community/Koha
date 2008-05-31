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
my ( $borr, $flags ) = GetMemberDetails( $borrowernumber );

# get branches and itemtypes
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

# get biblionumber.....
my $biblionumber = $query->param('biblionumber');
my $bibdata;
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
@CGIbranchlooparray =
  sort { $a->{branch} cmp $b->{branch} } @CGIbranchlooparray;
my $CGIbranchloop = \@CGIbranchlooparray;
$template->param( CGIbranch => $CGIbranchloop );

#### THIS IS A BIT OF A HACK BECAUSE THE BIBLIOITEMS DATA IS A LITTLE MESSED UP!
# get the itemtype data....
my @items = GetItemsInfo($biblionumber);
#######################################################
# old version, add so that old templates still work
my %types_old;
foreach my $itm (@items) {
    my $ity = $itm->{'itemtype'};
    unless ( $types_old{$ity} ) {
        $types_old{$ity}->{'itemtype'} = $ity;
        $types_old{$ity}->{'branchinfo'}->{ $itm->{'branchcode'} } = 1;
        $types_old{$ity}->{'description'} = $itm->{'description'};
    }
    else {
        $types_old{$ity}->{'branchinfo'}->{ $itm->{'branchcode'} }++;
    }
}

foreach my $type ( values %types_old ) {
    my $copies = "";
    foreach my $bc ( keys %{ $type->{'branchinfo'} } ) {
        $copies .=
            $branches->{$bc}->{'branchname'} . "("
          . $type->{'branchinfo'}->{$bc} . ")";
    }
    $type->{'copies'} = $copies;
}

my @types_old = values %types_old;

# end old version
################################

my @temp;
foreach my $itm (@items) {
    push @temp, $itm if $itm->{'itemtype'};
}
@items = @temp;
my $itemcount = @items;
$template->param( itemcount => $itemcount );

my %types;
my %itemtypes;
my @duedates;
#die @items;
my %itemhash;
my $forloan;
foreach my $itm (@items) {
    push @duedates, { date_due => format_date( $itm->{'date_due'} ) }
      if defined $itm->{'date_due'};
    $itm->{ $itm->{'publictype'} } = 1;
	warn $itm->{'notforloan'};
    my $fee = GetReserveFee( undef, $borrowernumber, $itm->{'biblionumber'},
        'a', ( $itm->{'biblioitemnumber'} ) );
    $fee = sprintf "%.02f", $fee;
    $itm->{'reservefee'} = $fee;
    my $pty = $itm->{'publictype'};
    $itemtypes{ $itm->{'itemtype'} } = $itm;
    unless ( $types{$pty} ) {
        $types{$pty}->{'count'} = 1;
        $types{$pty}->{ $itm->{'itemtype'} } = 1;
        push @{ $types{$pty}->{'items'} }, $itm;
    }
    else {
        unless ( $types{$pty}->{ $itm->{'itemtype'} } ) {
            $types{$pty}->{'count'}++;
            $types{$pty}->{ $itm->{'itemtype'} } = 1;
            push @{ $types{$pty}->{'items'} }, $itm;
        }
    }
	$itemhash{$itm->{'itemnumber'}}=$itm;
	if (!$itm->{'notforloan'} && !$itm->{'itemnotforloan'}){
		$forloan=1;
	}
}

$template->param( ITEMS => \@duedates );

my $width = keys %types;
my @publictypes = sort { $b->{'count'} <=> $a->{'count'} } values %types;
my $typecount;
foreach my $pt (@publictypes) {
    $typecount += $pt->{'count'};
}
$template->param( onlyone => 1 ) if $typecount == 1;

my @typerows;
for ( my $rownum = 0 ; $rownum < $publictypes[0]->{'count'} ; $rownum++ ) {
    my @row;
    foreach my $pty (@publictypes) {
        my @items = @{ $pty->{'items'} };
        push @row, $items[$rownum] if defined $items[$rownum];
    }
    my $last = @row;
    $row[ $last - 1 ]->{'last'} = 1 if $last == $width;
    my $fill = ( $width - $last ) * 2;
    $fill-- if $fill;
    push @typerows, { ROW => \@row, fill => $fill };
}
$template->param( TYPE_ROWS => \@typerows );
$width = 2 * $width - 1;
$template->param( totalwidth => 2 * $width - 1, );

if ( $query->param('place_reserve') ) {
    my @bibitems=$query->param('biblioitem');
    my $notes=$query->param('notes');
    my $checkitem=$query->param('checkitem');
    my $found;
    
    #if we have an item selectionned, and the pickup branch is the same as the holdingbranch of the document, we force the value $rank and $found.
    if ($checkitem ne ''){
        $rank = '0' unless C4::Context->preference('ReservesNeedReturns');
        my $item = $checkitem;
        $item = GetItem($item);
        if ( $item->{'holdingbranch'} eq $branch ){
            $found = 'W' unless C4::Context->preference('ReservesNeedReturns');
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
        $template->param( TYPES             => \@types_old );
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

    $biblioitem->{description} =
      $itemtypes->{ $biblioitem->{itemtype} }{description};

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
        
# 	add information
	$item->{itemcallnumber} = $item->{itemcallnumber};
	
        # if the item is currently on loan, we display its return date and
        # change the background color
        my $issues= GetItemIssue($itemnumber);
        if ( $issues->{'date_due'} ) {
            $item->{date_due} = format_date($issues->{'date_due'});
            $item->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my ($reservedate,$reservedfor,$expectedAt) = GetReservesFromItemnumber($itemnumber);
        my $ItemBorrowerReserveInfo = GetMemberDetails( $reservedfor, 0);

        if ( defined $reservedate ) {
            $item->{backgroundcolor} = 'reserved';
            $item->{reservedate}     = format_date($reservedate);
            $item->{ReservedForBorrowernumber}     = $reservedfor;
            $item->{ReservedForSurname}     = $ItemBorrowerReserveInfo->{'surname'};
            $item->{ReservedForFirstname}     = $ItemBorrowerReserveInfo->{'firstname'};
            $item->{ExpectedAtLibrary}     = $expectedAt;
            
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

	# FIXME: every library will define this differently
        # An item is available only if:
        if (
            not defined $reservedate    # not reserved yet
            and $issues->{'date_due'} eq ''         # not currently on loan
            and not $item->{itemlost}   # not lost
            and not $item->{notforloan} # not forbidden to loan
            and $transfertwhen eq ''    # not currently on transfert
          )
        {
            $item->{available} = 1;
        }

	# FIXME: move this to a pm
        my $dbh = C4::Context->dbh;
        my $sth2 = $dbh->prepare("SELECT * FROM reserves WHERE borrowernumber=? AND itemnumber=? AND found='W'");
        $sth2->execute($item->{ReservedForBorrowernumber},$item->{itemnumber});
        while (my $wait_hashref = $sth2->fetchrow_hashref) {
            $item->{waitingdate} = format_date($wait_hashref->{waitingdate});
        }
	$item->{imageurl} = getitemtypeimagesrc() . "/".$itemtypes->{ $item->{itype} }{imageurl};
        push @{ $biblioitem->{itemloop} }, $item;
    }

    push @bibitemloop, $biblioitem;
}

# display infos
$template->param(
	forloan           => $forloan,
    bibitemloop       => \@bibitemloop,
);
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
