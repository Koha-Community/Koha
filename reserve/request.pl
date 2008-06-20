#!/usr/bin/perl


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

=head1 request.pl

script to place reserves/requests

=cut

use strict;
use C4::Branch; # GetBranches get_branchinfos_of
use CGI;
use List::MoreUtils qw/uniq/;
use Date::Calc qw/Date_to_Days/;
use C4::Output;
use C4::Auth;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Circulation;
use C4::Dates qw/format_date/;
use C4::Members;

my $dbh = C4::Context->dbh;
my $sth;
my $input = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reserve/request.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reserveforothers => 1 },
    }
);

# get Branches and Itemtypes
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

# get biblio information....
my $biblionumber = $input->param('biblionumber');
my $dat          = GetBiblioData($biblionumber);

# Select borrowers infos
my $findborrower = $input->param('findborrower');
$findborrower =~ s|,| |g;
my $cardnumber = $input->param('cardnumber');
my $borrowerslist;
my $messageborrower;
my $warnings;
my $messages;

my $date = C4::Dates->today('iso');

if ($findborrower) {
    my ( $count, $borrowers ) =
      SearchMember($findborrower, 'cardnumber', 'web' );

    my @borrowers = @$borrowers;

    if ( $#borrowers == -1 ) {
        $input->param( 'findborrower', '' );
        $messageborrower = "'$findborrower'";
    }
    elsif ( $#borrowers == 0 ) {
        $input->param( 'cardnumber', $borrowers[0]->{'cardnumber'} );
        $cardnumber = $borrowers[0]->{'cardnumber'};
    }
    else {
        $borrowerslist = \@borrowers;
    }
}

if ($cardnumber) {
    my $borrowerinfo = GetMemberDetails( 0, $cardnumber );
    my $expiry;
    my $diffbranch;
    my @getreservloop;
    my $count_reserv = 0;
    my $maxreserves;

#   we check the reserves of the borrower, and if he can reserv a document
# FIXME At this time we have a simple count of reservs, but, later, we could improve the infos "title" ...

    my $number_reserves =
      GetReserveCount( $borrowerinfo->{'borrowernumber'} );

    if ( $number_reserves > C4::Context->preference('maxreserves') ) {
		$warnings = 1;
        $maxreserves = 1;
    }

    # we check the date expiricy of the borrower (only if there is an expiry date, otherwise, set to 1 (warn)
    if ($borrowerinfo->{'dateexpiry'} ne '0000-00-00') {
        my $warning = (Date_to_Days(split /-/,$date) > Date_to_Days( split /-/,$borrowerinfo->{'dateexpiry'}));
        if ( $warning > 0 ) {
			$messages = 1;
            $expiry = 1;
        }
    } else {
		$messages = 1;
        $expiry = 1;
    }
     

    # check if the borrower make the reserv in a different branch
    if ( $borrowerinfo->{'branchcode'} ne C4::Context->userenv->{'branch'} ) {
		$messages = 1;
        $diffbranch = 1;
    }

    $template->param(
                borrowernumber => $borrowerinfo->{'borrowernumber'},
                borrowersurname   => $borrowerinfo->{'surname'},
                borrowerfirstname => $borrowerinfo->{'firstname'},
                borrowerstreetaddress => $borrowerinfo->{'address'},
                borrowercity => $borrowerinfo->{'city'},
                borrowerphone => $borrowerinfo->{'phone'},
                borrowermobile => $borrowerinfo->{'mobile'},
                borrowerfax => $borrowerinfo->{'fax'},
                borrowerphonepro => $borrowerinfo->{'phonepro'},
                borroweremail => $borrowerinfo->{'email'},
                borroweremailpro => $borrowerinfo->{'emailpro'},
                borrowercategory => $borrowerinfo->{'category'},
                borrowerreservs   => $count_reserv,
                maxreserves       => $maxreserves,
                expiry            => $expiry,
                diffbranch        => $diffbranch,
				messages => $messages,
				warnings => $warnings
    );
}

$template->param( messageborrower => $messageborrower );

my $CGIselectborrower;
if ($borrowerslist) {
    my @values;
    my %labels;

    foreach my $borrower (
        sort {
                $a->{surname}
              . $a->{firstname} cmp $b->{surname}
              . $b->{firstname}
        } @{$borrowerslist}
      )
    {
        push @values, $borrower->{cardnumber};

        $labels{ $borrower->{cardnumber} } = sprintf(
            '%s, %s ... (%s - %s) ... %s',
            $borrower->{surname},    $borrower->{firstname},
            $borrower->{cardnumber}, $borrower->{categorycode},
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
my ( $count, $reserves ) = GetReservesFromBiblionumber($biblionumber);
my $totalcount = $count;
my $alreadyreserved;

# FIXME launch another time GetMemberDetails perhaps until
my $borrowerinfo = GetMemberDetails( 0, $cardnumber );

foreach my $res (@$reserves) {
    if ( ( $res->{found} eq 'W' ) ) {
        $count--;
    }

    if ( $borrowerinfo->{borrowernumber} eq $res->{borrowernumber} ) {
		$warnings = 1;
        $alreadyreserved = 1;
    }
}

$template->param( alreadyreserved => $alreadyreserved,
				messages => $messages,
				warnings => $warnings );

# FIXME think @optionloop, is maybe obsolete, or  must be switchable by a systeme preference fixed rank or not
# make priorities options

my @optionloop;
for ( 1 .. $count + 1 ) {
    push(
        @optionloop,
        {
            num      => $_,
            selected => ( $_ == $count + 1 ),
        }
    );
}
# adding a fixed value for priority options
my $fixedRank = $count+1;

my @branchcodes;
my %itemnumbers_of_biblioitem;
my @itemnumbers;

if (my $items = get_itemnumbers_of($biblionumber)->{$biblionumber}){
	@itemnumbers  = @$items;
}
else {
	$template->param('noitems' => 1);
}
	
my $iteminfos_of = GetItemInfosOf(@itemnumbers);

foreach my $itemnumber (@itemnumbers) {
    my $biblioitemnumber = $iteminfos_of->{$itemnumber}->{biblioitemnumber};
    push( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} }, $itemnumber );
}

my @biblioitemnumbers = keys %itemnumbers_of_biblioitem;

my $notforloan_label_of = get_notforloan_label_of();
my $biblioiteminfos_of  = GetBiblioItemInfosOf(@biblioitemnumbers);

my @bibitemloop;

foreach my $biblioitemnumber (@biblioitemnumbers) {
    my $biblioitem = $biblioiteminfos_of->{$biblioitemnumber};

    $biblioitem->{description} =
      $itemtypes->{ $biblioitem->{itemtype} }{description};

    foreach
      my $itemnumber ( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} } )
    {
        my $item = $iteminfos_of->{$itemnumber};
    $item->{itypename} = $itemtypes->{ $item->{itype} }{description};
    $item->{imageurl} = getitemtypeimagesrc() . "/".$itemtypes->{ $item->{itype} }{imageurl};
        $item->{homebranchname} =
          $branches->{ $item->{homebranch} }{branchname};

        # if the holdingbranch is different than the homebranch, we show the
        # holdingbranch of the document too
        if ( $item->{homebranch} ne $item->{holdingbranch} ) {
            $item->{holdingbranchname} =
              $branches->{ $item->{holdingbranch} }{branchname};
        }
        
#   add information
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
            $item->{ExpectedAtLibrary}     = $branches->{$expectedAt}{branchname};
            
        }

        # Management of the notforloan document
        if ( $item->{notforloan} ) {
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

        # Check the transit status
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
    
    # if independent branches is on we need to check if the person can reserve
    # for branches they arent logged in to
    if ( C4::Context->preference("IndependantBranches") ) { 
        if (! C4::Context->preference("canreservefromotherbranches")){
        # cant reserve items so need to check if item homebranch and userenv branch match if not we cant reserve
        my $userenv = C4::Context->userenv; 
        if ( ($userenv) && ( $userenv->{flags} != 1 ) ) {
            $item->{cantreserve} = 1 if ( $item->{homebranch} ne $userenv->{branch} );
        } 
        }
    }

    if (IsAvailableForItemLevelRequest($itemnumber) and not $item->{cantreserve}) {
        $item->{available} = 1;
    }

    # FIXME: move this to a pm
    my $sth2 = $dbh->prepare("SELECT * FROM reserves WHERE borrowernumber=? AND itemnumber=? AND found='W'");
    $sth2->execute($item->{ReservedForBorrowernumber},$item->{itemnumber});
    while (my $wait_hashref = $sth2->fetchrow_hashref) {
        $item->{waitingdate} = format_date($wait_hashref->{waitingdate});
    }
        push @{ $biblioitem->{itemloop} }, $item;
    }

    push @bibitemloop, $biblioitem;
}

# existingreserves building
my @reserveloop;
( $count, $reserves ) = GetReservesFromBiblionumber($biblionumber);
foreach my $res ( sort { $a->{found} cmp $b->{found} } @$reserves ) {
    my %reserve;
    my @optionloop;
    for ( my $i = 1 ; $i <= $totalcount ; $i++ ) {
        push(
            @optionloop,
            {
                num      => $i,
                selected => ( $i == $res->{priority} ),
            }
        );
    }
    my @branchloop;
    foreach my $br ( keys %$branches ) {
        my %abranch;
        $abranch{'selected'}   = ( $br eq $res->{'branchcode'} );
        $abranch{'branch'}     = $br;
        $abranch{'branchname'} = $branches->{$br}->{'branchname'};
        push( @branchloop, \%abranch );
    }

    if ( ( $res->{'found'} eq 'W' ) ) {
        my $item = $res->{'itemnumber'};
        $item = GetBiblioFromItemNumber($item,undef);
        $reserve{'wait'}= 1; 
        $reserve{'holdingbranch'}=$item->{'holdingbranch'};
        $reserve{'biblionumber'}=$item->{'biblionumber'};
        $reserve{'barcodenumber'}   = $item->{'barcode'};
        $reserve{'wbrcode'} = $res->{'branchcode'};
        $reserve{'itemnumber'}  = $res->{'itemnumber'};
        $reserve{'wbrname'} = $branches->{$res->{'branchcode'}}->{'branchname'};
        if($reserve{'holdingbranch'} eq $reserve{'wbrcode'}){
            $reserve{'atdestination'} = 1;
        }
        # set found to 1 if reserve is waiting for patron pickup
        $reserve{'found'} = 1 if $res->{'found'} eq 'W';
    }
    
#     get borrowers reserve info
my $reserveborrowerinfo = GetMemberDetails( $res->{'borrowernumber'}, 0);

    $reserve{'date'}           = format_date( $res->{'reservedate'} );
    $reserve{'borrowernumber'} = $res->{'borrowernumber'};
    $reserve{'biblionumber'}   = $res->{'biblionumber'};
    $reserve{'borrowernumber'} = $res->{'borrowernumber'};
    $reserve{'firstname'}      = $reserveborrowerinfo->{'firstname'};
    $reserve{'surname'}        = $reserveborrowerinfo->{'surname'};
    $reserve{'notes'}          = $res->{'reservenotes'};
    $reserve{'wait'}           =
      ( ( $res->{'found'} eq 'W' ) or ( $res->{'priority'} eq '0' ) );
    $reserve{'constrainttypea'} = ( $res->{'constrainttype'} eq 'a' );
    $reserve{'constrainttypeo'} = ( $res->{'constrainttype'} eq 'o' );
    $reserve{'voldesc'}         = $res->{'volumeddesc'};
    $reserve{'ccode'}           = $res->{'ccode'};
    $reserve{'barcode'}         = $res->{'barcode'};
    $reserve{'priority'}    = $res->{'priority'};
    $reserve{'branchloop'} = \@branchloop;
    $reserve{'optionloop'} = \@optionloop;

    push( @reserveloop, \%reserve );
}

my $default = C4::Context->userenv->{branch};
my @values;
my %label_of;

foreach my $branchcode (sort keys %{$branches} ) {
    push @values, $branchcode;
    $label_of{$branchcode} = $branches->{$branchcode}->{branchname};
}
my $CGIbranch = CGI::scrolling_list(
    -name     => 'pickup',
    -id          => 'pickup',
    -values   => \@values,
    -default  => $default,
    -labels   => \%label_of,
    -size     => 1,
    -multiple => 0,
);

# get the time for the form name...
my $time = time();

$template->param(
    CGIbranch   => $CGIbranch,
    reserveloop => \@reserveloop,
    time        => $time,
    fixedRank   => $fixedRank,
);

# display infos
$template->param(
    optionloop        => \@optionloop,
    bibitemloop       => \@bibitemloop,
    date              => $date,
    biblionumber      => $biblionumber,
    findborrower      => $findborrower,
    cardnumber        => $cardnumber,
    CGIselectborrower => $CGIselectborrower,
    title             => $dat->{title},
    author            => $dat->{author},
	holdsview => 1,
	borrower_branchname => $branches->{$borrowerinfo->{'branchcode'}}->{'branchname'},
	borrower_branchcode => $borrowerinfo->{'branchcode'},
);

# printout the page
output_html_with_http_headers $input, $cookie, $template->output;
