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

# $Id$

use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Reserves2;
use C4::Members;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Date;
use C4::Letters;
use C4::Branch; # GetBranches

my $query = new CGI;
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

# get borrower information ....
my ( $borr, $flags ) = GetMemberDetails( $borrowernumber );

$borr->{'dateenrolled'} = format_date( $borr->{'dateenrolled'} );
$borr->{'expiry'}       = format_date( $borr->{'expiry'} );
$borr->{'dateofbirth'}  = format_date( $borr->{'dateofbirth'} );
$borr->{'ethnicity'}    = fixEthnicity( $borr->{'ethnicity'} );

if ( $borr->{'debarred'} || $borr->{'gonenoaddress'} || $borr->{'lost'} ) {
    $borr->{'flagged'} = 1;
}

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

$template->param( BORROWER_INFO  => \@bordat );
$template->param( borrowernumber => $borrowernumber );

#get issued items ....
my $issues = GetBorrowerIssues($borr);

my $count          = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $imgdir = getitemtypeimagesrc();
my $itemtypes = GetItemTypes();
foreach my $issue ( @$issues ) {

    # check for reserves
    my ( $restype, $res ) = CheckReserves( $issue->{'itemnumber'} );
    if ( $restype ) {
        $issue->{'reserved'} = 1;
    }
    
    my ( $total , $accts, $numaccts) = GetBorrowerAcctRecord( $borrowernumber );
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
    my $status = CanBookBeRenewed( $borrowernumber, $issue->{'itemnumber'} );

    $issue->{'status'} = $status;

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
        $issue->{'imageurl'}    = $imgdir."/".$itemtypes->{$itemtype}->{'imageurl'};
        $issue->{'description'} = $itemtypes->{$itemtype}->{'description'};
    }
    push @issuedat, $issue;
    $count++;
}

$template->param( ISSUES       => \@issuedat );
$template->param( issues_count => $count );

$template->param( OVERDUES       => \@overdues );
$template->param( overdues_count => $overdues_count );

my $branches = GetBranches();

# now the reserved items....
my ( $rcount, $reserves ) = FindReserves( undef, $borrowernumber );
foreach my $res (@$reserves) {
    $res->{'reservedate'} = format_date( $res->{'reservedate'} );
    my $publictype = $res->{'publictype'};
    $res->{$publictype} = 1;
    $res->{'waiting'} = 1 if $res->{'found'} eq 'W';
    $res->{'branch'} = $branches->{ $res->{'branchcode'} }->{'branchname'};
    my $biblioData = GetBiblioData($res->{'biblionumber'});
    $res->{'reserves_title'} = $biblioData->{'title'};
}

$template->param( RESERVES       => $reserves );
$template->param( reserves_count => $rcount );

my @waiting;
my $wcount = 0;
foreach my $res (@$reserves) {
    if ( $res->{'itemnumber'} ) {
        my $item = GetItem( $res->{'itemnumber'});
        $res->{'holdingbranch'} =
          $branches->{ $item->{'holdingbranch'} }->{'branchname'};
        $res->{'branch'} = $branches->{ $res->{'branchcode'} }->{'branchname'};
        if ( $res->{'holdingbranch'} eq $res->{'branch'} ) {
            $res->{'atdestination'} = 1;
        }
        my $biblioData = GetBiblioData($res->{'biblionumber'});
        $res->{'waiting_title'} = $biblioData->{'title'};
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

$template->param(
    waiting_count      => $wcount,
    textmessaging      => $borr->{textmessaging},
);

output_html_with_http_headers $query, $cookie, $template->output;

