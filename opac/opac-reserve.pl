#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Output;       # gettemplate
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Reserves2;

my $MAXIMUM_NUMBER_OF_RESERVES = 5;


my $query = new CGI;


my $flagsrequired;
$flagsrequired->{borrow}=1;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired);


my $template = gettemplate("opac-reserve.tmpl", "opac");

# get borrower information ....
my $borrowernumber = getborrowernumber($loggedinuser);
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
my @bordat;
$bordat[0] = $borr;
$template->param(BORROWER_INFO => \@bordat);

# get biblionumber.....
my $biblionumber = $query->param('bib');
$template->param(biblionumber => $biblionumber);

my $bibdata = bibdata($biblionumber);
$template->param($bibdata);

# get the rank number....
my ($rank,$reserves) = FindReserves($biblionumber);
foreach my $res (@$reserves) {
    if ($res->{'found'} eq 'W') {
	$rank--;
    }
}

$template->param(rank => $rank);
$rank++;


# pass the pickup branch along....
my $branch = $query->param('branch');
$template->param(branch => $branch);

my $branches = getbranches();
$template->param(branchname => $branches->{$branch}->{'branchname'});


# make branch selection options...
my $branchoptions = '';
foreach my $br (keys %$branches) {
    (next) unless $branches->{$br}->{'IS'};
    my $selected = "";
    if ($br eq 'L') {
	$selected = "selected";
    }
    $branchoptions .= "<option value=$br $selected>$branches->{$br}->{'branchname'}</option>\n";
}
$template->param( branchoptions => $branchoptions);

#### THIS IS A BIT OF A HACK BECAUSE THE BIBLIOITEMS DATA IS A LITTLE MESSED UP!
# get the itemtype data....
my @items = ItemInfo(undef, $biblionumber, 'intra');
my %types;
foreach my $itm (@items) {
    my $ity = $itm->{'itemtype'};
    unless ($types {$ity}) {
	$types{$ity}->{'itemtype'} = $ity;
	$types{$ity}->{'branchinfo'}->{$itm->{'branchcode'}} = 1;
	$types{$ity}->{'description'} = $itm->{'description'};	
    } else {
	$types{$ity}->{'branchinfo'}->{$itm->{'branchcode'}} ++;
    }
}

foreach my $type (values %types) {
    my $copies = "";
    foreach my $bc (keys %{$type->{'branchinfo'}}) {
	$copies .= $branches->{$bc}->{'branchname'}."(".$type->{'branchinfo'}->{$bc}.")";
    }
    $type->{'copies'} = $copies;
}

my @types = values %types;


if ($query->param('item_types_selected')) {
# this is what happens after the itemtypes have been selected. Stage 2
    my @itemtypes = $query->param('itemtype');
    if (@itemtypes) {
	warn "Itemtypes : @itemtypes\n";
	my %newtypes;
	foreach my $itmtype (@itemtypes) {
	    $newtypes{$itmtype} = $types{$itmtype};
	}
	my @types = values %newtypes;
	$template->param(TYPES => \@types);
	$template->param(item_types_selected => 1);

	my %reqbibs;
	foreach my $item (@items) {
	    foreach my $type (@itemtypes) {
		if ($item->{'itemtype'} == $type) {
		    $reqbibs{$item->{'biblioitemnumber'}} = 1;
		}
	    }
	}
	my @reqbibs = keys %reqbibs;
	my $fee = CalcReserveFee(undef,$borrowernumber,$biblionumber,'o',\@reqbibs);
	$fee = sprintf "%.02f", $fee;
	$template->param(fee => $fee);
    } else {
	$template->param(message => 1);
	$template->param(no_items_selected => 1);
    }

} elsif ($query->param('place_reserve')) {
# here we actually do the reserveration. Stage 3.
    my $title = $bibdata->{'title'};
    my %reqbibs;
    my @itemtypes = $query->param('itemtype');
    foreach my $item (@items) {
	foreach my $type (@itemtypes) {
	    if ($item->{'itemtype'} == $type) {
		$reqbibs{$item->{'biblioitemnumber'}} = 1;
	    }
	}
    }
    my @reqbibs = keys %reqbibs;
    CreateReserve(undef,$branch,$borrowernumber,$biblionumber,'o',\@reqbibs,$rank,'',$title);
    print $query->redirect("/cgi-bin/koha/opac-user.pl");
} else {
# Here we check that the borrower can actually make reserves Stage 1.
    my $noreserves = 0;
    if ($borr->{'amountoutstanding'} > 5) {
  	my $amount = sprintf "\$%.02f", $borr->{'amountoutstanding'};
	$template->param(message => 1);
	$noreserves = 1;
	$template->param(too_much_oweing => $amount);
    }
    my ($resnum, $reserves) = FindReserves(undef, $borrowernumber); 
    $template->param(RESERVES => $reserves);
    if ($resnum >= $MAXIMUM_NUMBER_OF_RESERVES) {
	$template->param(message => 1);
	$noreserves = 1;
	$template->param(too_many_reserves => $resnum);
    }
    foreach my $res (@$reserves) {
	if ($res->{'biblionumber'} == $biblionumber) {
	    $template->param(message => 1);
	    $noreserves = 1;
	    $template->param(already_reserved => 1);
	}
    }
    $template->param(TYPES => \@types);
    unless ($noreserves) {
	$template->param(select_item_types => 1);
    }
}


$template->param(loggedinuser => $loggedinuser);
print "Content-Type: text/html\n\n", $template->output; 
