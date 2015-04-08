#!/usr/bin/perl


#writen 2/1/00 by chris@katipo.oc.nz
# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2011 Catalyst IT
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

=head1 request.pl

script to place reserves/requests

=cut

use strict;
use warnings;
use C4::Branch;
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
use C4::Search;		# enabled_staff_search_views
use Koha::DateUtils;

my $dbh = C4::Context->dbh;
my $sth;
my $input = new CGI;
my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "reserve/request.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reserveforothers => 'place_holds' },
    }
);

my $multihold = $input->param('multi_hold');
$template->param(multi_hold => $multihold);
my $showallitems = $input->param('showallitems');

# get Branches and Itemtypes
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

my $userbranch = '';
if (C4::Context->userenv && C4::Context->userenv->{'branch'}) {
    $userbranch = C4::Context->userenv->{'branch'};
}


# Select borrowers infos
my $findborrower = $input->param('findborrower');
$findborrower = '' unless defined $findborrower;
$findborrower =~ s|,| |g;
my $borrowernumber_hold = $input->param('borrowernumber') || '';
my $messageborrower;
my $maxreserves;
my $warnings;
my $messages;

my $date = C4::Dates->today('iso');
my $action = $input->param('action');
$action ||= q{};

if ( $action eq 'move' ) {
  my $where = $input->param('where');
  my $reserve_id = $input->param('reserve_id');
  AlterPriority( $where, $reserve_id );
} elsif ( $action eq 'cancel' ) {
  my $reserve_id = $input->param('reserve_id');
  CancelReserve({ reserve_id => $reserve_id });
} elsif ( $action eq 'setLowestPriority' ) {
  my $reserve_id = $input->param('reserve_id');
  ToggleLowestPriority( $reserve_id );
} elsif ( $action eq 'toggleSuspend' ) {
  my $reserve_id = $input->param('reserve_id');
  my $suspend_until  = $input->param('suspend_until');
  ToggleSuspend( $reserve_id, $suspend_until );
}

if ($findborrower) {
    my $borrowers = Search($findborrower, 'cardnumber');

    if ($borrowers && @$borrowers) {
        if ( @$borrowers == 1 ) {
            $borrowernumber_hold = $borrowers->[0]->{'borrowernumber'};
        }
        else {
            $template->param( borrower_list => sort_borrowerlist($borrowers));
        }
    } else {
        $messageborrower = "'$findborrower'";
    }
}

# If we have the borrowernumber because we've performed an action, then we
# don't want to try to place another reserve.
if ($borrowernumber_hold && !$action) {
    my $borrowerinfo = GetMember( borrowernumber => $borrowernumber_hold );
    my $diffbranch;
    my @getreservloop;
    my $count_reserv = 0;

    # we check the reserves of the borrower, and if he can reserv a document
    # FIXME At this time we have a simple count of reservs, but, later, we could improve the infos "title" ...

    my $number_reserves =
      GetReserveCount( $borrowerinfo->{'borrowernumber'} );

    if ( C4::Context->preference('maxreserves') && ($number_reserves >= C4::Context->preference('maxreserves')) ) {
        $warnings = 1;
        $maxreserves = 1;
    }

    # we check the date expiry of the borrower (only if there is an expiry date, otherwise, set to 1 (warn)
    my $expiry_date = $borrowerinfo->{dateexpiry};
    my $expiry = 0; # flag set if patron account has expired
    if ($expiry_date and $expiry_date ne '0000-00-00' and
        Date_to_Days(split /-/,$date) > Date_to_Days(split /-/,$expiry_date)) {
        $expiry = 1;
    }

    # check if the borrower make the reserv in a different branch
    if ( $borrowerinfo->{'branchcode'} ne C4::Context->userenv->{'branch'} ) {
        $diffbranch = 1;
    }

    $template->param(
                borrowernumber      => $borrowerinfo->{'borrowernumber'},
                borrowersurname     => $borrowerinfo->{'surname'},
                borrowerfirstname   => $borrowerinfo->{'firstname'},
                borrowerstreetaddress   => $borrowerinfo->{'address'},
                borrowercity        => $borrowerinfo->{'city'},
                borrowerphone       => $borrowerinfo->{'phone'},
                borrowermobile      => $borrowerinfo->{'mobile'},
                borrowerfax         => $borrowerinfo->{'fax'},
                borrowerphonepro    => $borrowerinfo->{'phonepro'},
                borroweremail       => $borrowerinfo->{'email'},
                borroweremailpro    => $borrowerinfo->{'emailpro'},
                borrowercategory    => $borrowerinfo->{'category'},
                borrowerreservs     => $count_reserv,
                cardnumber          => $borrowerinfo->{'cardnumber'},
                expiry              => $expiry,
                diffbranch          => $diffbranch,
                messages            => $messages,
                warnings            => $warnings
    );
}

$template->param( messageborrower => $messageborrower );

# FIXME launch another time GetMember perhaps until
my $borrowerinfo = GetMember( borrowernumber => $borrowernumber_hold );

my @biblionumbers = ();
my $biblionumbers = $input->param('biblionumbers');
if ($multihold) {
    @biblionumbers = split '/', $biblionumbers;
} else {
    push @biblionumbers, $input->param('biblionumber');
}

my $itemdata_enumchron = 0;
my @biblioloop = ();
foreach my $biblionumber (@biblionumbers) {

    my %biblioloopiter = ();

    my $dat = GetBiblioData($biblionumber);

    my $canReserve = CanBookBeReserved( $borrowerinfo->{borrowernumber}, $biblionumber );
    if ( $canReserve eq 'OK' ) {

        #All is OK and we can continue
    }
    elsif ( $canReserve eq 'tooManyReserves' ) {
        $maxreserves = 1;
    }
    elsif ( $canReserve eq 'ageRestricted' ) {
        $template->param( $canReserve => 1 );
        $biblioloopiter{$canReserve} = 1;
    }
    else {
        $biblioloopiter{$canReserve} = 1;
    }

    my $alreadypossession;
    if (not C4::Context->preference('AllowHoldsOnPatronsPossessions') and CheckIfIssuedToPatron($borrowerinfo->{borrowernumber},$biblionumber)) {
        $alreadypossession = 1;
    }

    # get existing reserves .....
    my $reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber, all_dates => 1 });
    my $count = scalar( @$reserves );
    my $totalcount = $count;
    my $holds_count = 0;
    my $alreadyreserved = 0;

    foreach my $res (@$reserves) {
        if ( defined $res->{found} ) { # found can be 'W' or 'T'
            $count--;
        }

        if ( defined $borrowerinfo && defined($borrowerinfo->{borrowernumber}) && ($borrowerinfo->{borrowernumber} eq $res->{borrowernumber}) ) {
            $holds_count++;
        }
    }

    if ( $holds_count ) {
            $alreadyreserved = 1;
            $biblioloopiter{warn} = 1;
            $biblioloopiter{alreadyres} = 1;
    }

    $template->param(
        alreadyreserved => $alreadyreserved,
        alreadypossession => $alreadypossession,
    );

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

    ## $items is array of 'item' table numbers
    if (my $items = get_itemnumbers_of($biblionumber)->{$biblionumber}){
        @itemnumbers  = @$items;
    }
    my @hostitems = get_hostitemnumbers_of($biblionumber);
    if (@hostitems){
        $template->param('hostitemsflag' => 1);
        push(@itemnumbers, @hostitems);
    }

    if (!@itemnumbers) {
        $template->param('noitems' => 1);
        $biblioloopiter{noitems} = 1;
    }

    ## Hash of item number to 'item' table fields
    my $iteminfos_of = GetItemInfosOf(@itemnumbers);

    ## Here we go backwards again to create hash of biblioitemnumber to itemnumbers,
    ## when by definition all of the itemnumber have the same biblioitemnumber
    foreach my $itemnumber (@itemnumbers) {
        my $biblioitemnumber = $iteminfos_of->{$itemnumber}->{biblioitemnumber};
        push( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} }, $itemnumber );
    }

    ## Should be same as biblionumber
    my @biblioitemnumbers = keys %itemnumbers_of_biblioitem;

    my $notforloan_label_of = get_notforloan_label_of();

    ## Hash of biblioitemnumber to 'biblioitem' table records
    my $biblioiteminfos_of  = GetBiblioItemInfosOf(@biblioitemnumbers);

    my @bibitemloop;

    foreach my $biblioitemnumber (@biblioitemnumbers) {
        my $biblioitem = $biblioiteminfos_of->{$biblioitemnumber};
        my $num_available = 0;
        my $num_override  = 0;
        my $hiddencount   = 0;

        $biblioitem->{description} =
          $itemtypes->{ $biblioitem->{itemtype} }{description};
	if($biblioitem->{biblioitemnumber} ne $biblionumber){
		$biblioitem->{hostitemsflag}=1;
	}
        $biblioloopiter{description} = $biblioitem->{description};
        $biblioloopiter{itypename} = $biblioitem->{description};
        $biblioloopiter{imageurl} =
          getitemtypeimagelocation('intranet', $itemtypes->{$biblioitem->{itemtype}}{imageurl});

        foreach my $itemnumber ( @{ $itemnumbers_of_biblioitem{$biblioitemnumber} } )    {
            my $item = $iteminfos_of->{$itemnumber};

            unless (C4::Context->preference('item-level_itypes')) {
                $item->{itype} = $biblioitem->{itemtype};
            }

            $item->{itypename} = $itemtypes->{ $item->{itype} }{description};
            $item->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $item->{itype} }{imageurl} );
            $item->{homebranchname} = $branches->{ $item->{homebranch} }{branchname};

            # if the holdingbranch is different than the homebranch, we show the
            # holdingbranch of the document too
            if ( $item->{homebranch} ne $item->{holdingbranch} ) {
                $item->{holdingbranchname} =
                  $branches->{ $item->{holdingbranch} }{branchname};
            }

		if($item->{biblionumber} ne $biblionumber){
			$item->{hostitemsflag}=1;
		        $item->{hosttitle} = GetBiblioData($item->{biblionumber})->{title};
		}
		
            #   add information
            $item->{itemcallnumber} = $item->{itemcallnumber};

            # if the item is currently on loan, we display its return date and
            # change the background color
            my $issues= GetItemIssue($itemnumber);
            if ( $issues->{'date_due'} ) {
                $item->{date_due} = format_sqldatetime($issues->{date_due});
                $item->{backgroundcolor} = 'onloan';
            }

            # checking reserve
            my ($reservedate,$reservedfor,$expectedAt,$reserve_id,$wait) = GetReservesFromItemnumber($itemnumber);
            my $ItemBorrowerReserveInfo = GetMember( borrowernumber => $reservedfor );

            if ( defined $reservedate ) {
                $item->{backgroundcolor} = 'reserved';
                $item->{reservedate}     = format_date($reservedate);
                $item->{ReservedForBorrowernumber}     = $reservedfor;
                $item->{ReservedForSurname}     = $ItemBorrowerReserveInfo->{'surname'};
                $item->{ReservedForFirstname}     = $ItemBorrowerReserveInfo->{'firstname'};
                $item->{ExpectedAtLibrary}     = $branches->{$expectedAt}{branchname};
                $item->{waitingdate} = $wait;
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
                if (GetHideLostItemsPreference($borrowernumber) && !$showallitems) {
                    $item->{hide} = 1;
                    $hiddencount++;
                }
            }

            # Check the transit status
            my ( $transfertwhen, $transfertfrom, $transfertto ) =
              GetTransfers($itemnumber);

            if ( defined $transfertwhen && $transfertwhen ne '' ) {
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
            if ( C4::Context->preference("IndependentBranches") ) {
                if (! C4::Context->preference("canreservefromotherbranches")){
                    # cant reserve items so need to check if item homebranch and userenv branch match if not we cant reserve
                    my $userenv = C4::Context->userenv;
                    unless ( C4::Context->IsSuperLibrarian ) {
                        $item->{cantreserve} = 1 if ( $item->{homebranch} ne $userenv->{branch} );
                    }
                }
            }

            my $branch = C4::Circulation::_GetCircControlBranch($item, $borrowerinfo);

            my $branchitemrule = GetBranchItemRule( $branch, $item->{'itype'} );
            my $policy_holdallowed = 1;

            $item->{'holdallowed'} = $branchitemrule->{'holdallowed'};

            if ( $branchitemrule->{'holdallowed'} == 0 ||
                 ( $branchitemrule->{'holdallowed'} == 1 &&
                     $borrowerinfo->{'branchcode'} ne $item->{'homebranch'} ) ) {
                $policy_holdallowed = 0;
            }
            
            if (
                   $policy_holdallowed
                && !$item->{cantreserve}
                && IsAvailableForItemLevelRequest($itemnumber)
                && CanItemBeReserved(
                    $borrowerinfo->{borrowernumber}, $itemnumber
                ) eq 'OK'
              )
            {
                $item->{available} = 1;
                $num_available++;
            }
            elsif ( C4::Context->preference('AllowHoldPolicyOverride') ) {
                # If AllowHoldPolicyOverride is set, it should override EVERY restriction, not just branch item rules
                $item->{override} = 1;
                $num_override++;
            }

            # If none of the conditions hold true, then neither override nor available is set and the item cannot be checked

            # Show serial enumeration when needed
            if ($item->{enumchron}) {
                $itemdata_enumchron = 1;
            }

            push @{ $biblioitem->{itemloop} }, $item;
        }

        if ( $num_override == scalar( @{ $biblioitem->{itemloop} } ) ) { # That is, if all items require an override
            $template->param( override_required => 1 );
        } elsif ( $num_available == 0 ) {
            $template->param( none_available => 1 );
            $biblioloopiter{warn} = 1;
            $biblioloopiter{none_avail} = 1;
        }
        $template->param( hiddencount => $hiddencount);

        push @bibitemloop, $biblioitem;
    }

    # existingreserves building
    my @reserveloop;
    $reserves = GetReservesFromBiblionumber({ biblionumber => $biblionumber, all_dates => 1 });
    foreach my $res ( sort {
            my $a_found = $a->{found} || '';
            my $b_found = $a->{found} || '';
            $a_found cmp $b_found;
        } @$reserves ) {
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

        if ( defined $res->{'found'} && ($res->{'found'} eq 'W' || $res->{'found'} eq 'T' )) {
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
                # Just because the holdingbranch matches the reserve branch doesn't mean the item
                # has arrived at the destination, check for an open transfer for the item as well
                my ( $transfertwhen, $transfertfrom, $transferto ) = C4::Circulation::GetTransfers( $res->{itemnumber} );
                if ( not $transferto or $transferto ne $res->{branchcode} ) {
                    $reserve{'atdestination'} = 1;
                }
            }
            # set found to 1 if reserve is waiting for patron pickup
            $reserve{'found'} = 1 if $res->{'found'} eq 'W';
            $reserve{'intransit'} = 1 if $res->{'found'} eq 'T';
        } elsif ($res->{priority} > 0) {
            if (defined($res->{itemnumber})) {
                my $item = GetItem($res->{itemnumber});
                $reserve{'itemnumber'}  = $res->{'itemnumber'};
                $reserve{'barcodenumber'}   = $item->{'barcode'};
                $reserve{'item_level_hold'} = 1;
            }
        }

        #     get borrowers reserve info
        my $reserveborrowerinfo = GetMember( borrowernumber => $res->{'borrowernumber'} );
        if (C4::Context->preference('HidePatronName')){
	    $reserve{'hidename'} = 1;
	    $reserve{'cardnumber'} = $reserveborrowerinfo->{'cardnumber'};
	}
        $reserve{'expirationdate'} = format_date( $res->{'expirationdate'} )
            unless ( !defined($res->{'expirationdate'}) || $res->{'expirationdate'} eq '0000-00-00' );
        $reserve{'date'}           = format_date( $res->{'reservedate'} );
        $reserve{'borrowernumber'} = $res->{'borrowernumber'};
        $reserve{'biblionumber'}   = $res->{'biblionumber'};
        $reserve{'borrowernumber'} = $res->{'borrowernumber'};
        $reserve{'firstname'}      = $reserveborrowerinfo->{'firstname'};
        $reserve{'surname'}        = $reserveborrowerinfo->{'surname'};
        $reserve{'notes'}          = $res->{'reservenotes'};
        $reserve{'wait'}           =
          ( ( defined $res->{'found'} and $res->{'found'} eq 'W' ) or ( $res->{'priority'} eq '0' ) );
        $reserve{'constrainttypea'} = ( $res->{'constrainttype'} eq 'a' );
        $reserve{'constrainttypeo'} = ( $res->{'constrainttype'} eq 'o' );
        $reserve{'voldesc'}         = $res->{'volumeddesc'};
        $reserve{'ccode'}           = $res->{'ccode'};
        $reserve{'barcode'}         = $res->{'barcode'};
        $reserve{'priority'}    = $res->{'priority'};
        $reserve{'lowestPriority'}    = $res->{'lowestPriority'};
        $reserve{'optionloop'} = \@optionloop;
        $reserve{'suspend'} = $res->{'suspend'};
        $reserve{'suspend_until'} = $res->{'suspend_until'};
        $reserve{'reserve_id'} = $res->{'reserve_id'};

        if ( C4::Context->preference('IndependentBranches') && $flags->{'superlibrarian'} != 1 ) {
              $reserve{'branchloop'} = [ GetBranchDetail($res->{'branchcode'}) ];
        } else {
              $reserve{'branchloop'} = GetBranchesLoop($res->{'branchcode'});
        }

        push( @reserveloop, \%reserve );
    }

    # get the time for the form name...
    my $time = time();

    $template->param(
                     branchloop  => GetBranchesLoop($userbranch),
                     time        => $time,
                     fixedRank   => $fixedRank,
                    );

    # display infos
    $template->param(
                     optionloop        => \@optionloop,
                     bibitemloop       => \@bibitemloop,
                     itemdata_enumchron => $itemdata_enumchron,
                     date              => $date,
                     biblionumber      => $biblionumber,
                     findborrower      => $findborrower,
                     title             => $dat->{title},
                     author            => $dat->{author},
                     holdsview => 1,
                     C4::Search::enabled_staff_search_views,
                    );
    if (defined $borrowerinfo && exists $borrowerinfo->{'branchcode'}) {
        $template->param(
                     borrower_branchname => $branches->{$borrowerinfo->{'branchcode'}}->{'branchname'},
                     borrower_branchcode => $borrowerinfo->{'branchcode'},
        );
    }

    $biblioloopiter{biblionumber} = $biblionumber;
    $biblioloopiter{title} = $dat->{title};
    $biblioloopiter{rank} = $fixedRank;
    $biblioloopiter{reserveloop} = \@reserveloop;

    if (@reserveloop) {
        $template->param( reserveloop => \@reserveloop );
    }

    push @biblioloop, \%biblioloopiter;
}

$template->param( biblioloop => \@biblioloop );
$template->param( biblionumbers => $biblionumbers );
$template->param( maxreserves => $maxreserves );

if ($multihold) {
    $template->param( multi_hold => 1 );
}

if ( C4::Context->preference( 'AllowHoldDateInFuture' ) ) {
    $template->param( reserve_in_future => 1 );
}

$template->param(
    SuspendHoldsIntranet => C4::Context->preference('SuspendHoldsIntranet'),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
);

# printout the page
output_html_with_http_headers $input, $cookie, $template->output;

sub sort_borrowerlist {
    my $borrowerslist = shift;
    my $ref           = [];
    push @{$ref}, sort {
        uc( $a->{surname} . $a->{firstname} ) cmp
          uc( $b->{surname} . $b->{firstname} )
    } @{$borrowerslist};
    return $ref;
}
