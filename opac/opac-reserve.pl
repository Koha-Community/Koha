#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;

use C4::Search;
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Reserves2;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;
use C4::Context;

my $MAXIMUM_NUMBER_OF_RESERVES = C4::Context->preference("maxreserves");

my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-reserve.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
my @bordat;
$bordat[0] = $borr;

# get biblionumber.....
my $biblionumber = $query->param('bib');

my $bibdata = bibdata($biblionumber);
 $template->param($bibdata);
 $template->param(BORROWER_INFO => \@bordat, biblionumber => $biblionumber);

# get the rank number....
my ($rank,$reserves) = FindReserves($biblionumber,'');
$template->param(reservecount => $rank);

foreach my $res (@$reserves) {
    if ($res->{'found'} eq 'W') {
	$rank--;
    }
}

$rank++;
$template->param(rank => $rank);

# pass the pickup branch along....
my $branch = $query->param('branch');
$template->param(branch => $branch);

my $branches = getbranches();
$template->param(branchname => $branches->{$branch}->{'branchname'});


# make branch selection options...
#my $branchoptions = '';
my @branches;
my @select_branch;
my %select_branches;

foreach my $branch (keys %$branches) {
	if ($branch) {
		push @select_branch, $branch;
		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
	}
}
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
			-values   => \@select_branch,
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );
$template->param( CGIbranch => $CGIbranch);

#### THIS IS A BIT OF A HACK BECAUSE THE BIBLIOITEMS DATA IS A LITTLE MESSED UP!
# get the itemtype data....
my @items = ItemInfo(undef, $biblionumber, 'opac');

#######################################################
# old version, add so that old templates still work
my %types_old;
foreach my $itm (@items) {
    my $ity = $itm->{'itemtype'};
    unless ($types_old {$ity}) {
	$types_old{$ity}->{'itemtype'} = $ity;
	$types_old{$ity}->{'branchinfo'}->{$itm->{'branchcode'}} = 1;
	$types_old{$ity}->{'description'} = $itm->{'description'};
    } else {
	$types_old{$ity}->{'branchinfo'}->{$itm->{'branchcode'}} ++;
    }
}

foreach my $type (values %types_old) {
    my $copies = "";
    foreach my $bc (keys %{$type->{'branchinfo'}}) {
	$copies .= $branches->{$bc}->{'branchname'}."(".$type->{'branchinfo'}->{$bc}.")";
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
$template->param(itemcount => $itemcount);

my %types;
my %itemtypes;
my @duedates;
foreach my $itm (@items) {
    push @duedates, {date_due => format_date($itm->{'date_due'})} if defined $itm->{'date_due'};
    $itm->{$itm->{'publictype'}} = 1;
    # FIXME CalcReserveFee is supposed to be internal-use-only
    my $fee  = CalcReserveFee(undef, $borrowernumber, $itm->{'biblionumber'},'a',($itm->{'biblioitemnumber'}));
    $fee = sprintf "%.02f", $fee;
    $itm->{'reservefee'} = $fee;
    my $pty = $itm->{'publictype'};
    $itemtypes{$itm->{'itemtype'}} = $itm;
    unless ($types {$pty}) {
	$types{$pty}->{'count'} = 1;
	$types{$pty}->{$itm->{'itemtype'}} = 1;
	push @{$types{$pty}->{'items'}}, $itm;
    } else {
	unless ($types{$pty}->{$itm->{'itemtype'}}) {
	    $types{$pty}->{'count'}++;
	    $types{$pty}->{$itm->{'itemtype'}} = 1;
	    push @{$types{$pty}->{'items'}}, $itm;
	}
    }
}


$template->param(ITEMS => \@duedates);

my $width = keys %types;
my @publictypes = sort {$b->{'count'} <=> $a->{'count'}} values %types;
my $typecount;
foreach my $pt (@publictypes) {
    $typecount += $pt->{'count'};
}
$template->param(onlyone => 1) if $typecount == 1;

my @typerows;
for (my $rownum=0;$rownum<$publictypes[0]->{'count'} ;$rownum++) {
    my @row;
    foreach my $pty (@publictypes) {
	my @items = @{$pty->{'items'}};
	push @row, $items[$rownum] if defined $items[$rownum];
    }
    my $last = @row;
    $row[$last-1]->{'last'} =1 if $last == $width;
    my $fill = ($width - $last)*2;
    $fill-- if $fill;
    push @typerows, {ROW => \@row, fill => $fill};
}
$template->param(TYPE_ROWS => \@typerows);
$width = 2*$width -1;
$template->param(totalwidth => 2*$width-1);

if ($query->param('item_types_selected')) {
	# this is what happens after the itemtypes have been selected. Stage 2
	my @itemtypes = $query->param('itemtype');
	my $fee = 0;
	my $proceed = 0;
	if (@itemtypes) {
		my %newtypes;
		foreach my $itmtype (@itemtypes) {
		$newtypes{$itmtype} = $itemtypes{$itmtype};
		}
		my @types = values %newtypes;
		$template->param(TYPES => \@types);
		foreach my $type (@itemtypes) {
		my @reqbibs;
		foreach my $item (@items) {
			if ($item->{'itemtype'} eq $type) {
			push @reqbibs, $item->{'biblioitemnumber'};
			}
		}
		$fee += CalcReserveFee(undef,$borrowernumber,$biblionumber,'o',\@reqbibs);
		}
		$proceed = 1;
	} elsif ($query->param('all')) {
		$template->param(all => 1);
		$fee = 1;
		$proceed = 1;
	}
	warn "branch :$branch:";
	if ($proceed && $branch) {
		$fee = sprintf "%.02f", $fee;
		$template->param(fee => $fee);
		$template->param(item_types_selected => 1);
	} else {
		$template->param(message => 1);
		$template->param(no_items_selected => 1) unless ($proceed);
		$template->param(no_branch_selected =>1) unless ($branch);
	}
} elsif ($query->param('place_reserve')) {
	# here we actually do the reserveration. Stage 3.
	my $title = $bibdata->{'title'};
	my @itemtypes = $query->param('itemtype');
	foreach my $type (@itemtypes) {
		my @reqbibs;
		foreach my $item (@items) {
		if ($item->{'itemtype'} eq $type) {
			push @reqbibs, $item->{'biblioitemnumber'};
		}
		}
		CreateReserve(undef,$branch,$borrowernumber,$biblionumber,'o',\@reqbibs,$rank,'',$title);
	}
	if ($query->param('all')) {
		CreateReserve(undef,$branch,$borrowernumber,$biblionumber,'a', undef, $rank,'',$title);
	}
	print $query->redirect("/cgi-bin/koha/opac-search.pl");
} else {
	# Here we check that the borrower can actually make reserves Stage 1.
	my $noreserves = 0;
	my $maxoutstanding = C4::Context->preference("maxoustanding");
	if ($borr->{'amountoutstanding'} > $maxoutstanding) {
		my $amount = sprintf "\$%.02f", $borr->{'amountoutstanding'};
		$template->param(message => 1);
		$noreserves = 1;
		$template->param(too_much_oweing => $amount);
	}
	my ($resnum, $reserves) = FindReserves('', $borrowernumber);
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
	unless ($noreserves) {
		$template->param(TYPES => \@types_old);
		$template->param(select_item_types => 1);
	}
}

# check that you can actually make the reserve.

output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
