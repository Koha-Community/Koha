#!/usr/bin/perl

# This file is part of Koha.
# parts copyright 2010 BibLibre
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


use strict;
#use warnings; FIXME - Bug 2505

use CGI;

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Members;
use C4::Members::AttributeTypes;
use C4::Members::Attributes qw/GetBorrowerAttributeValue/;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Letters;
use C4::Branch; # GetBranches
use Koha::DateUtils;
use Koha::Borrower::Debarments qw(IsDebarred);

use constant ATTRIBUTE_SHOW_BARCODE => 'SHOW_BCODE';

use Date::Calc qw(
  Today
  Add_Delta_Days
  Date_to_Days
);

my $query = new CGI;

BEGIN {
    if (C4::Context->preference('BakerTaylorEnabled')) {
        require C4::External::BakerTaylor;
        import C4::External::BakerTaylor qw(&image_url &link_url);
    }
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

my %renewed = map { $_ => 1 } split( ':', $query->param('renewed') );

my $show_priority;
for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
    m/priority/ and $show_priority = 1;
}

my $patronupdate = $query->param('patronupdate');
my $canrenew = 1;

$template->param( shibbolethAuthentication => C4::Context->config('useshibboleth') );

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

my (  $today_year,   $today_month,   $today_day) = Today();
my ($warning_year, $warning_month, $warning_day) = split /-/, $borr->{'dateexpiry'};

$borr->{'ethnicity'} = fixEthnicity( $borr->{'ethnicity'} );

my $debar = IsDebarred($borrowernumber);
my $userdebarred;

if ($debar) {
    $userdebarred = 1;
    $template->param( 'userdebarred' => $userdebarred );
    if ( $debar ne "9999-12-31" ) {
        $borr->{'userdebarreddate'} = $debar;
    }
}

if ( $userdebarred || $borr->{'gonenoaddress'} || $borr->{'lost'} ) {
    $borr->{'flagged'} = 1;
    $canrenew = 0;
}

if ( $borr->{'amountoutstanding'} > 5 ) {
    $borr->{'amountoverfive'} = 1;
}
if ( 5 >= $borr->{'amountoutstanding'} && $borr->{'amountoutstanding'} > 0 ) {
    $borr->{'amountoverzero'} = 1;
}
my $no_renewal_amt = C4::Context->preference( 'OPACFineNoRenewals' );
$no_renewal_amt ||= 0;

if (  C4::Context->preference( 'OpacRenewalAllowed' ) && $borr->{amountoutstanding} > $no_renewal_amt ) {
    $borr->{'flagged'} = 1;
    $canrenew = 0;
    $template->param(
        renewal_blocked_fines => sprintf( '%.02f', $no_renewal_amt ),
        renewal_blocked_fines_amountoutstanding => sprintf( '%.02f', $borr->{amountoutstanding} ),
    );
}

if ( $borr->{'amountoutstanding'} < 0 ) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1 * ( $borr->{'amountoutstanding'} );
}

$borr->{'amountoutstanding'} = sprintf "%.02f", $borr->{'amountoutstanding'};

my @bordat;
$bordat[0] = $borr;

# Warningdate is the date that the warning starts appearing
if ( $borr->{'dateexpiry'} && C4::Context->preference('NotifyBorrowerDeparture') ) {
    my $days_to_expiry = Date_to_Days( $warning_year, $warning_month, $warning_day ) - Date_to_Days( $today_year, $today_month, $today_day );
    if ( $days_to_expiry < 0 ) {
        #borrower card has expired, warn the borrower
        $borr->{'warnexpired'} = $borr->{'dateexpiry'};
    } elsif ( $days_to_expiry < C4::Context->preference('NotifyBorrowerDeparture') ) {
        # borrower card soon to expire, warn the borrower
        $borr->{'warndeparture'} = $borr->{dateexpiry};
        if (C4::Context->preference('ReturnBeforeExpiry')){
            $borr->{'returnbeforeexpiry'} = 1;
        }
    }
}

# pass on any renew errors to the template for displaying
my $renew_error = $query->param('renew_error');

$template->param(   BORROWER_INFO     => \@bordat,
                    borrowernumber    => $borrowernumber,
                    patron_flagged    => $borr->{flagged},
                    OPACMySummaryHTML => (C4::Context->preference("OPACMySummaryHTML")) ? 1 : 0,
                    surname           => $borr->{surname},
                    showname          => $borr->{showname},
                    RENEW_ERROR       => $renew_error,
                    borrower          => $borr,
                );

#get issued items ....

my $count          = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $itemtypes = GetItemTypes();
my $issues = GetPendingIssues($borrowernumber);
if ($issues){
    foreach my $issue ( sort { $b->{date_due}->datetime() cmp $a->{date_due}->datetime() } @{$issues} ) {
        # check for reserves
        my $restype = GetReserveStatus( $issue->{'itemnumber'} );
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
                  if $ac->{'accounttype'} eq 'FU';
                $charges += $ac->{'amountoutstanding'}
                  if $ac->{'accounttype'} eq 'L';
            }
        }
        $issue->{'charges'} = $charges;
        $issue->{'subtitle'} = GetRecordValue('subtitle', GetMarcBiblio($issue->{'biblionumber'}), GetFrameworkCode($issue->{'biblionumber'}));
        # check if item is renewable
        my ($status,$renewerror) = CanBookBeRenewed( $borrowernumber, $issue->{'itemnumber'} );
        ($issue->{'renewcount'},$issue->{'renewsallowed'},$issue->{'renewsleft'}) = GetRenewCount($borrowernumber, $issue->{'itemnumber'});
        if($status && C4::Context->preference("OpacRenewalAllowed")){
            $issue->{'status'} = $status;
        }

        $issue->{'renewed'} = $renewed{ $issue->{'itemnumber'} };

        if ($renewerror) {
            $issue->{'too_many'}       = 1 if $renewerror eq 'too_many';
            $issue->{'on_reserve'}     = 1 if $renewerror eq 'on_reserve';
            $issue->{'auto_renew'}     = 1 if $renewerror eq 'auto_renew';
            $issue->{'auto_too_soon'}  = 1 if $renewerror eq 'auto_too_soon';

            if ( $renewerror eq 'too_soon' ) {
                $issue->{'too_soon'}         = 1;
                $issue->{'soonestrenewdate'} = output_pref(
                    C4::Circulation::GetSoonestRenewDate(
                        $issue->{borrowernumber},
                        $issue->{itemnumber}
                    )
                );
            }
        }

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
        push @issuedat, $issue;
        $count++;

        my $isbn = GetNormalizedISBN($issue->{'isbn'});
        $issue->{normalized_isbn} = $isbn;

                # My Summary HTML
                if (my $my_summary_html = C4::Context->preference('OPACMySummaryHTML')){
                    $issue->{author} ? $my_summary_html =~ s/{AUTHOR}/$issue->{author}/g : $my_summary_html =~ s/{AUTHOR}//g;
                    $issue->{title} =~ s/\/+$//; # remove trailing slash
                    $issue->{title} =~ s/\s+$//; # remove trailing space
                    $issue->{title} ? $my_summary_html =~ s/{TITLE}/$issue->{title}/g : $my_summary_html =~ s/{TITLE}//g;
                    $issue->{isbn} ? $my_summary_html =~ s/{ISBN}/$isbn/g : $my_summary_html =~ s/{ISBN}//g;
                    $issue->{biblionumber} ? $my_summary_html =~ s/{BIBLIONUMBER}/$issue->{biblionumber}/g : $my_summary_html =~ s/{BIBLIONUMBER}//g;
                    $issue->{MySummaryHTML} = $my_summary_html;
                }
    }
}
$template->param( ISSUES       => \@issuedat );
$template->param( issues_count => $count );
$template->param( canrenew     => $canrenew );
$template->param( OVERDUES       => \@overdues );
$template->param( overdues_count => $overdues_count );

my $show_barcode = C4::Members::AttributeTypes::AttributeTypeExists( ATTRIBUTE_SHOW_BARCODE );
if ($show_barcode) {
    my $patron_show_barcode = GetBorrowerAttributeValue($borrowernumber, ATTRIBUTE_SHOW_BARCODE);
    undef $show_barcode if defined($patron_show_barcode) && !$patron_show_barcode;
}
$template->param( show_barcode => 1 ) if $show_barcode;

# load the branches
my $branches = GetBranches();
my @branch_loop;
for my $branch_hash ( sort keys %{$branches} ) {
    my $selected;
    if ( C4::Context->preference('SearchMyLibraryFirst') ) {
        $selected =
          ( C4::Context->userenv
              && ( $branch_hash eq C4::Context->userenv->{branch} ) );
    }
    push @branch_loop,
      { value      => "branch: $branch_hash",
        branchname => $branches->{$branch_hash}->{'branchname'},
        selected   => $selected,
      };
}
$template->param( branchloop => \@branch_loop );

# now the reserved items....
my @reserves  = GetReservesFromBorrowernumber( $borrowernumber );
foreach my $res (@reserves) {

    if ( $res->{'expirationdate'} eq '0000-00-00' ) {
      $res->{'expirationdate'} = '';
    }
    $res->{'subtitle'} = GetRecordValue('subtitle', GetMarcBiblio($res->{'biblionumber'}), GetFrameworkCode($res->{'biblionumber'}));
    $res->{'waiting'} = 1 if $res->{'found'} eq 'W';
    $res->{'branch'} = $branches->{ $res->{'branchcode'} }->{'branchname'};
    my $biblioData = GetBiblioData($res->{'biblionumber'});
    $res->{'reserves_title'} = $biblioData->{'title'};
    $res->{'author'} = $biblioData->{'author'};

    if ($show_priority) {
        $res->{'priority'} ||= '';
    }
    $res->{'suspend_until'} = C4::Dates->new( $res->{'suspend_until'}, "iso")->output("syspref") if ( $res->{'suspend_until'} );
}

# use Data::Dumper;
# warn Dumper(@reserves);

$template->param( RESERVES       => \@reserves );
$template->param( reserves_count => $#reserves+1 );
$template->param( showpriority=>$show_priority );

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
            $res->{'barcode'} = $item->{'barcode'};
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
                $res->{datesent}   = $transfertwhen;
                $res->{frombranch} = GetBranchName($transfertfrom);
            }
        }
        push @waiting, $res;
        $wcount++;
    }
    # can be cancelled
    #$res->{'cancelable'} = 1 if ($res->{'wait'} && $res->{'atdestination'} && $res->{'found'} ne "1");
    $res->{'cancelable'} = 1 if    ($res->{wait} and not $res->{found}) or (not $res->{wait} and not $res->{intransit});

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

if ( GetMessagesCount( $borrowernumber, 'B' ) ) {
    $template->param( bor_messages => 1 );
}

if ( $borr->{'opacnote'} ) {
  $template->param( 
    bor_messages => 1,
    opacnote => $borr->{'opacnote'},
  );
}

$template->param(
    bor_messages_loop    => GetMessages( $borrowernumber, 'B', 'NONE' ),
    waiting_count      => $wcount,
    patronupdate => $patronupdate,
    OpacRenewalAllowed => C4::Context->preference("OpacRenewalAllowed"),
    userview => 1,
);

$template->param(
    SuspendHoldsOpac => C4::Context->preference('SuspendHoldsOpac'),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
    OpacHoldNotes => C4::Context->preference('OpacHoldNotes'),
);

output_html_with_http_headers $query, $cookie, $template->output;

