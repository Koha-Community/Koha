#!/usr/bin/perl

# $Id$

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz


# Copyright 2000-2002 Katipo Communications
#
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
use HTML::Template;
use CGI;
use Date::Manip;
use List::MoreUtils qw/uniq/;
use Data::Dumper;

use C4::Search;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Reserves2;
use C4::Biblio;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Acquisition;
use C4::Date;
use C4::Members;

my $dbh = C4::Context->dbh;
my $sth;
my $input = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({
        template_name => "reserve/request.tmpl",
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => {reserveforothers => 1},
    });

# get biblio information....
my $bib = $input->param('bib');
my $dat = bibdata($bib);

# Select borrowers infos
my $findborrower = $input->param('findborrower');
$findborrower =~ s|,| |g;
my $cardnumber = $input->param('cardnumber');
my %env;
my $borrowerslist;
my $messageborrower;

my $date = today();

if ($findborrower) {
    my ($count,$borrowers) =  BornameSearch(\%env, $findborrower, 'cardnumber', 'web');

    my @borrowers = @$borrowers;

    if ($#borrowers == -1) {
        $input->param('findborrower', '');
        $messageborrower =  "'$findborrower'";
    }
    elsif ($#borrowers == 0) {
        $input->param('cardnumber', $borrowers[0]->{'cardnumber'});
        $cardnumber = $borrowers[0]->{'cardnumber'};
    }
    else {
        $borrowerslist = \@borrowers;
    }
}

if ($cardnumber) {
	my $borrowerinfo = getpatroninformation (\%env,0,$cardnumber);
	my $expiry;
	my $diffbranch;
	my @getreservloop;
	my $count_reserv = 0;
	my $maxreserves;

# 	we check the reserves of the borrower, and if he can reserv a document
# FIXME At this time we have a simple count of reservs, but, later, we could improve the infos "title" ...

        my $number_reserves =
            GetNumberReservesFromBorrower($borrowerinfo->{'borrowernumber'});

        if ($number_reserves > C4::Context->preference('maxreserves')) {
            $maxreserves = 1;
        }

# we check the date expiricy of the borrower
	my $warning=Date_Cmp(ParseDate("today"),format_date($borrowerinfo->{'dateexpiry'}));
	if ( $warning > 0) {
			$expiry = 1;
	}

# check if the borrower make the reserv in a different branch
	if ($borrowerinfo->{'branchcode'} ne C4::Context->userenv->{'branch'}) {
		$diffbranch = 1;
	}

	$template->param(
		borrowersurname => $borrowerinfo->{'surname'},
		borrowerfirstname => $borrowerinfo->{'firstname'},
		borrowerreservs => $count_reserv,
		maxreserves => $maxreserves,
		expiry => $expiry,
		diffbranch => $diffbranch
	);
}

$template->param(
    messageborrower => $messageborrower
);

my $CGIselectborrower;
if ($borrowerslist) {
    my @values;
    my %labels;

    foreach my $borrower (
        sort {$a->{surname}.$a->{firstname} cmp $b->{surname}.$b->{firstname}}
            @{$borrowerslist}
    ) {
        push @values, $borrower->{cardnumber};

        $labels{ $borrower->{cardnumber} } = sprintf(
            '%s, %s ... (%s - %s) ... %s',
            $borrower->{surname},
            $borrower->{firstname},
            $borrower->{cardnumber},
            $borrower->{categorycode},
            $borrower->{streetaddress},
        );
    }

    $CGIselectborrower = CGI::scrolling_list(
        -name     => 'cardnumber',
        -values   => \@values,
        -labels   => \%labels,
        -size     => 7,
        -multiple => 0,
    );
}

# get existing reserves .....
my ($count, $reserves) = FindReserves($bib, undef);
my $totalcount = $count;
my $alreadyreserved;

# FIXME launch another time getpatroninformation perhaps until
my $borrowerinfo = getpatroninformation (\%env,0,$cardnumber);

foreach my $res (@$reserves) {
    if (($res->{found} eq 'W') or ($res->{priority} == 0)) {
	$count--;
    }

    if ($borrowerinfo->{borrowernumber} eq $res->{borrowernumber}) {
	$alreadyreserved = 1;
    }
}
$template->param(alreadyreserved => $alreadyreserved);

# make priorities options
my @optionloop;
for (1 .. $count + 1) {
    push(
        @optionloop,
        {
            num => $_,
            selected => ($_ == $count + 1),
        }
    );
}

my @branchcodes;
my %itemnumbers_of_biblioitem;
my @itemnumbers = @{get_itemnumbers_of($bib)->{$bib}};
my $iteminfos_of = get_iteminfos_of(@itemnumbers);

foreach my $itemnumber (@itemnumbers) {
    push(
        @branchcodes,
        $iteminfos_of->{$itemnumber}->{homebranch},
        $iteminfos_of->{$itemnumber}->{holdingbranch}
    );

    my $biblioitemnumber = $iteminfos_of->{$itemnumber}->{biblioitemnumber};
    push(
        @{ $itemnumbers_of_biblioitem{$biblioitemnumber} },
        $itemnumber
    );
}

@branchcodes = uniq @branchcodes;

my @biblioitemnumbers = keys %itemnumbers_of_biblioitem;

my $branchinfos_of = get_branchinfos_of(@branchcodes);
my $notforloan_label_of = get_notforloan_label_of();
my $biblioiteminfos_of = get_biblioiteminfos_of(@biblioitemnumbers);

my @itemtypes;
foreach my $biblioitemnumber (@biblioitemnumbers) {
    push @itemtypes, $biblioiteminfos_of->{$biblioitemnumber}{itemtype};
}

my $itemtypeinfos_of = get_itemtypeinfos_of(@itemtypes);

my $return_date_of = get_current_return_date_of(@itemnumbers);

my @bibitemloop;

foreach my $biblioitemnumber (@biblioitemnumbers) {
    my $biblioitem = $biblioiteminfos_of->{$biblioitemnumber};

    $biblioitem->{description} =
        $itemtypeinfos_of->{ $biblioitem->{itemtype} }{description};

    foreach my $itemnumber (@{$itemnumbers_of_biblioitem{$biblioitemnumber}}) {
        my $item = $iteminfos_of->{$itemnumber};

        $item->{homebranchname} =
            $branchinfos_of->{ $item->{homebranch} }{branchname};

        # if the holdingbranch is different than the homebranch, we show the
        # holdingbranch of the document too
        if ($item->{homebranch} ne $item->{holdingbranch}) {
            $item->{holdingbranchname} =
                $branchinfos_of->{ $item->{holdingbranch} }{branchname};
        }

        # if the item is currently on loan, we display its return date and
        # change the background color
        my $date_due;

        if (defined $return_date_of->{$itemnumber}) {
            $date_due = format_date($return_date_of->{$itemnumber});
	    $item->{date_due} = $date_due;
            $item->{backgroundcolor} = 'onloan';
        }

        # checking reserve
        my $reservedate = GetFirstReserveDateFromItem($itemnumber);

        if (defined $reservedate) {
            $item->{backgroundcolor} = 'reserved';
            $item->{reservedate} = format_date($reservedate);
        }

        # Management of the notforloan document
        if ($item->{notforloan}) {
            $item->{backgroundcolor} = 'other';
            $item->{notforloanvalue} =
                $notforloan_label_of->{ $item->{notforloan} };
        }

        # Management of lost or long overdue items
        if ($item->{itemlost}) {

            # FIXME localized strings should never be in Perl code
            $item->{message} = $item->{itemlost} == 1
                ? "(lost)"
                : $item->{itemlost} == 2
                    ? "(long overdue)"
                    : "";
            $item->{backgroundcolor} = 'other';
        }

        # Check of the transfered documents 
        my ($transfertwhen,$transfertfrom,$transfertto) =
            get_transfert_infos($itemnumber);

        if ($transfertwhen ne '') {
            $item->{transfertwhen} = format_date($transfertwhen);
            $item->{transfertfrom} =
                $branchinfos_of->{$transfertfrom}{branchname};
            $item->{transfertto} =
                $branchinfos_of->{$transfertto}{branchname};
        }

        # If there is no loan, return and transfer, we show a checkbox.
        $item->{notforloan} = $item->{notforloan} || 0;

        # An item is available only if:
        if (not defined $reservedate      # not reserved yet
            and $date_due eq ''           # not currently on loan
            and not $item->{itemlost}     # not lost
            and not $item->{notforloan}   # not forbidden to loan
            and $transfertwhen eq ''      # not currently on transfert
        ) {
            $item->{available} = 1;
        }

        push @{$biblioitem->{itemloop}}, $item;
    }

    push @bibitemloop, $biblioitem;
}


# existingreserves building
my @reserveloop;
my $branches = getbranches();
foreach my $res (sort {$a->{found} cmp $b->{found}} @$reserves){
    my %reserve;
    my @optionloop;
    for (my $i=1; $i <= $totalcount; $i++) {
        push(
            @optionloop,
            {
                num => $i,
                selected => ($i == $res->{priority}),
            }
        );
    }
    my @branchloop;
    foreach my $br (keys %$branches) {
        my %abranch;
        $abranch{'selected'}=($br eq $res->{'branchcode'});
        $abranch{'branch'}=$br;
        $abranch{'branchname'}=$branches->{$br}->{'branchname'};
        push(@branchloop,\%abranch);
    }

    if (($res->{'found'} eq 'W') or ($res->{'priority'} eq '0')) {
        my %env;
        my $item = $res->{'itemnumber'};
        $item = getiteminformation(\%env,$item);
        $reserve{'holdingbranch'}=$item->{'holdingbranch'};
        $reserve{'barcode'}=$item->{'barcode'};
        $reserve{'biblionumber'}=$item->{'biblionumber'};
        $reserve{'wbrcode'} = $res->{'branchcode'};
        $reserve{'wbrname'} = $branches->{$res->{'branchcode'}}->{'branchname'};
        if($reserve{'holdingbranch'} eq $reserve{'wbrcode'}){
            $reserve{'atdestination'} = 1;
        }
    }

    $reserve{'date'} = format_date($res->{'reservedate'});
    $reserve{'borrowernumber'}=$res->{'borrowernumber'};
    $reserve{'biblionumber'}=$res->{'biblionumber'};
    $reserve{'bornum'}=$res->{'borrowernumber'};
    $reserve{'firstname'}=$res->{'firstname'};
    $reserve{'surname'}=$res->{'surname'};
    $reserve{'bornum'}=$res->{'borrowernumber'};
    $reserve{'notes'}=$res->{'reservenotes'};
    $reserve{'wait'}=(($res->{'found'} eq 'W') or ($res->{'priority'} eq '0'));
    $reserve{'constrainttypea'}=($res->{'constrainttype'} eq 'a');
    $reserve{'constrainttypeo'}=($res->{'constrainttype'} eq 'o');
    $reserve{'voldesc'}=$res->{'volumeddesc'};
    $reserve{'itemtype'}=$res->{'itemtype'};
    $reserve{'branchloop'}=\@branchloop;
    $reserve{'optionloop'}=\@optionloop;

    push(@reserveloop,\%reserve);
}

my $default = C4::Context->userenv->{branch};
my @values;
my %label_of;

foreach my $branchcode (keys %{$branches}) {
    push @values, $branchcode;
    $label_of{$branchcode} = $branches->{$branchcode}->{branchname};
}

my $CGIbranch = CGI::scrolling_list(
    -name     => 'pickup',
    -values   => \@values,
    -default  => $default,
    -labels   => \%label_of,
    -size     => 1,
    -multiple => 0,
);

# get the time for the form name...
my $time = time();

$template->param(
    CGIbranch => $CGIbranch,
    reserveloop => \@reserveloop,
    time => $time,
);

# setup colors
$template->param(
    optionloop =>\@optionloop,
    bibitemloop => \@bibitemloop,
    date => $date,
    bib => $bib,
    findborrower => $findborrower,
    cardnumber => $cardnumber,
    CGIselectborrower => $CGIselectborrower,
    title =>$dat->{title},
);

# printout the page
print $input->header(
	-type => C4::Interface::CGI::Output::guesstype($template->output),
	-expires=>'now'
), $template->output;
