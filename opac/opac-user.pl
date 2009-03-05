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

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Members;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Dates qw/format_date/;
use C4::Letters;
use C4::Branch; # GetBranches

my $query = new CGI;

BEGIN {
    if (C4::Context->preference('BakerTaylorEnabled')) {
        require C4::External::BakerTaylor;
        import C4::External::BakerTaylor qw(&image_url &link_url);
    }
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

my $OPACDisplayRequestPriority = (C4::Context->preference("OPACDisplayRequestPriority")) ? 1 : 0;
my $patronupdate = $query->param('patronupdate');

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

$borr->{'dateenrolled'} = format_date( $borr->{'dateenrolled'} );
$borr->{'expiry'}       = format_date( $borr->{'expiry'} );
$borr->{'dateofbirth'}  = format_date( $borr->{'dateofbirth'} );
$borr->{'ethnicity'}    = fixEthnicity( $borr->{'ethnicity'} );

if ( $borr->{'debarred'} || $borr->{'gonenoaddress'} || $borr->{'lost'} ) {
    $borr->{'flagged'} = 1;
}
# $make flagged available everywhere in the template
my $patron_flagged = $borr->{'flagged'};
if ( $borr->{'amountoutstanding'} > 5 ) {
    $borr->{'amountoverfive'} = 1;
}
if ( 5 >= $borr->{'amountoutstanding'} && $borr->{'amountoutstanding'} > 0 ) {
    $borr->{'amountoverzero'} = 1;
}
if ( $borr->{'amountoutstanding'} < 0 ) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1 * ( $borr->{'amountoutstanding'} );
}

$borr->{'amountoutstanding'} = sprintf "%.02f", $borr->{'amountoutstanding'};

my @bordat;
$bordat[0] = $borr;

$template->param(   BORROWER_INFO  => \@bordat,
                    borrowernumber => $borrowernumber,
                    patron_flagged => $patron_flagged,
                );

#get issued items ....
my ($issues) = GetPendingIssues($borrowernumber);
my @issue_list = sort { $b->{'date_due'} cmp $a->{'date_due'} } @$issues;

my $count          = 0;
my $toggle = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $itemtypes = GetItemTypes();
foreach my $issue ( @issue_list ) {
    if($count%2 eq 0){ $issue->{'toggle'} = 1; } else { $issue->{'toggle'} = 0; }
    # check for reserves
    my ( $restype, $res ) = CheckReserves( $issue->{'itemnumber'} );
    if ( $restype ) {
        $issue->{'reserved'} = 1;
    }
    
    my ( $total , $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );
    my $charges = 0;
    foreach my $ac (@$accts) {
        if ( $ac->{'itemnumber'} == $issue->{'itemnumber'} ) {
            $charges += $ac->{'amountoutstanding'}
              if $ac->{'accounttype'} eq 'F';
            $charges += $ac->{'amountoutstanding'}
              if $ac->{'accounttype'} eq 'L';
        }
    }
    $issue->{'charges'} = $charges;

    # get publictype for icon

    my $publictype = $issue->{'publictype'};
    $issue->{$publictype} = 1;

    # check if item is renewable
    my ($status,$renewerror) = CanBookBeRenewed( $borrowernumber, $issue->{'itemnumber'} );
    ($issue->{'renewcount'},$issue->{'renewsallowed'},$issue->{'renewsleft'}) = GetRenewCount($borrowernumber, $issue->{'itemnumber'});

    $issue->{'status'} = $status || C4::Context->preference("OpacRenewalAllowed");

    if ( $issue->{'overdue'} ) {
        push @overdues, $issue;
        $overdues_count++;
        $issue->{'overdue'} = 1;
    }
    else {
        $issue->{'issued'} = 1;
    }
    # imageurl:
    my $itemtype = $issue->{'itemtype'};
    if ( $itemtype ) {
        $issue->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{$itemtype}->{'imageurl'} );
        $issue->{'description'} = $itemtypes->{$itemtype}->{'description'};
    }
    $issue->{date_due} = format_date($issue->{date_due});
    push @issuedat, $issue;
    $count++;
    
    my $isbn = GetNormalizedISBN($issue->{'isbn'});
    $issue->{normalized_isbn} = $isbn;
}

$template->param( ISSUES       => \@issuedat );
$template->param( issues_count => $count );

$template->param( OVERDUES       => \@overdues );
$template->param( overdues_count => $overdues_count );

# load the branches
my $branches = GetBranches();
my @branch_loop;
for my $branch_hash (sort keys %$branches ) {
    my $selected=(C4::Context->userenv && ($branch_hash eq C4::Context->userenv->{branch})) if (C4::Context->preference('SearchMyLibraryFirst'));
    push @branch_loop,
      {
        value      => "branch: $branch_hash",
        branchname => $branches->{$branch_hash}->{'branchname'},
        selected => $selected
      };
}
$template->param( branchloop => \@branch_loop, "mylibraryfirst"=>C4::Context->preference("SearchMyLibraryFirst"));

# now the reserved items....
my @reserves  = GetReservesFromBorrowernumber( $borrowernumber );
foreach my $res (@reserves) {
    $res->{'reservedate'} = format_date( $res->{'reservedate'} );
    my $publictype = $res->{'publictype'};
    $res->{$publictype} = 1;
    $res->{'waiting'} = 1 if $res->{'found'} eq 'W';
    $res->{'branch'} = $branches->{ $res->{'branchcode'} }->{'branchname'};
    my $biblioData = GetBiblioData($res->{'biblionumber'});
    $res->{'reserves_title'} = $biblioData->{'title'};
    if ($OPACDisplayRequestPriority) {
        $res->{'priority'} = '' if $res->{'priority'} eq '0';
    }
}

# use Data::Dumper;
# warn Dumper(@reserves);

$template->param( RESERVES       => \@reserves );
$template->param( reserves_count => $#reserves+1 );
$template->param( showpriority=>1 ) if $OPACDisplayRequestPriority;

my @waiting;
my $wcount = 0;
foreach my $res (@reserves) {
    if ( $res->{'itemnumber'} ) {
        my $item = GetItem( $res->{'itemnumber'});
        $res->{'holdingbranch'} =
          $branches->{ $item->{'holdingbranch'} }->{'branchname'};
        $res->{'branch'} = $branches->{ $res->{'branchcode'} }->{'branchname'};
        # get document reserve status
        my $biblioData = GetBiblioData($res->{'biblionumber'});
        $res->{'waiting_title'} = $biblioData->{'title'};
        if ( ( $res->{'found'} eq 'W' ) ) {
            my $item = $res->{'itemnumber'};
            $item = GetBiblioFromItemNumber($item,undef);
            $res->{'wait'}= 1; 
            $res->{'holdingbranch'}=$item->{'holdingbranch'};
            $res->{'biblionumber'}=$item->{'biblionumber'};
            $res->{'barcodenumber'} = $item->{'barcode'};
            $res->{'wbrcode'} = $res->{'branchcode'};
            $res->{'itemnumber'}    = $res->{'itemnumber'};
            $res->{'wbrname'} = $branches->{$res->{'branchcode'}}->{'branchname'};
            if($res->{'holdingbranch'} eq $res->{'wbrcode'}){
                $res->{'atdestination'} = 1;
            }
            # set found to 1 if reserve is waiting for patron pickup
            $res->{'found'} = 1 if $res->{'found'} eq 'W';
        } else {
            my ($transfertwhen, $transfertfrom, $transfertto) = GetTransfers( $res->{'itemnumber'} );
            if ($transfertwhen) {
                $res->{intransit} = 1;
                $res->{datesent}   = format_date($transfertwhen);
                $res->{frombranch} = GetBranchName($transfertfrom);
            }
        }
        push @waiting, $res;
        $wcount++;
    }
}

$template->param( WAITING => \@waiting );

# current alert subscriptions
my $alerts = getalert($borrowernumber);
foreach ( @$alerts ) {
    $_->{ $_->{type} } = 1;
    $_->{relatedto} = findrelatedto( $_->{type}, $_->{externalid} );
}

if (C4::Context->preference('BakerTaylorEnabled')) {
    $template->param(
        BakerTaylorEnabled  => 1,
        BakerTaylorImageURL => &image_url(),
        BakerTaylorLinkURL  => &link_url(),
        BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
    );
}

if (C4::Context->preference("OPACAmazonCoverImages") or 
    C4::Context->preference("GoogleJackets") or
    C4::Context->preference("BakerTaylorEnabled") or
	C4::Context->preference("SyndeticsCoverImages")) {
        $template->param(JacketImages=>1);
}

$template->param(
    waiting_count      => $wcount,
    textmessaging      => $borr->{textmessaging},
    patronupdate => $patronupdate,
    OpacRenewalAllowed => C4::Context->preference("OpacRenewalAllowed"),
    userview => 1,
    dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $query, $cookie, $template->output;

