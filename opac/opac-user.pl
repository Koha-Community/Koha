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

use CGI qw ( -utf8 );

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
use Koha::Patron::Debarments qw(IsDebarred);
use Koha::Holds;
use Koha::Database;
use Koha::Patron::Messages;

use constant ATTRIBUTE_SHOW_BARCODE => 'SHOW_BCODE';

use Scalar::Util qw(looks_like_number);
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

if (!$borrowernumber) {
    $template->param( adminWarning => 1 );
}

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

my (  $today_year,   $today_month,   $today_day) = Today();
my ($warning_year, $warning_month, $warning_day) = split /-/, $borr->{'dateexpiry'};

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
$no_renewal_amt = undef unless looks_like_number( $no_renewal_amt );

if (   C4::Context->preference('OpacRenewalAllowed')
    && defined($no_renewal_amt)
    && $borr->{amountoutstanding} > $no_renewal_amt )
{
    $borr->{'flagged'} = 1;
    $canrenew = 0;
    $template->param(
        renewal_blocked_fines => sprintf( '%.02f', $no_renewal_amt ),
        renewal_blocked_fines_amountoutstanding =>
          sprintf( '%.02f', $borr->{amountoutstanding} ),
    );
}

if ( $borr->{'amountoutstanding'} < 0 ) {
    $borr->{'amountlessthanzero'} = 1;
    $borr->{'amountoutstanding'} = -1 * ( $borr->{'amountoutstanding'} );
}

$borr->{'amountoutstanding'} = sprintf "%.02f", $borr->{'amountoutstanding'};

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

$template->param(   BORROWER_INFO     => $borr,
                    borrowernumber    => $borrowernumber,
                    patron_flagged    => $borr->{flagged},
                    OPACMySummaryHTML => (C4::Context->preference("OPACMySummaryHTML")) ? 1 : 0,
                    surname           => $borr->{surname},
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
        my $marcrecord = GetMarcBiblio( $issue->{'biblionumber'} );
        $issue->{'subtitle'} = GetRecordValue('subtitle', $marcrecord, GetFrameworkCode($issue->{'biblionumber'}));
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
            $issue->{'norenew_overdue'} = 1 if $renewerror eq 'overdue';
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
        $issue->{normalized_upc} = GetNormalizedUPC( $marcrecord, C4::Context->preference('marcflavour') );

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
my $overduesblockrenewing = C4::Context->preference('OverduesBlockRenewing');
$canrenew = 0 if ($overduesblockrenewing ne 'allow' and $overdues_count == $count);
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
my $reserves = Koha::Holds->search( { borrowernumber => $borrowernumber } );

$template->param(
    RESERVES       => $reserves,
    showpriority   => $show_priority,
);

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

my $patron_messages = Koha::Patron::Messages->search(
    {
        borrowernumber => $borrowernumber,
        message_type => 'B',
    }
);
if ( $patron_messages->count ) {
    $template->param( bor_messages => 1 );
}

if ( $borr->{'opacnote'} ) {
  $template->param( 
    bor_messages => 1,
    opacnote => $borr->{'opacnote'},
  );
}

if (   C4::Context->preference('AllowPatronToSetCheckoutsVisibilityForGuarantor')
    || C4::Context->preference('AllowStaffToSetCheckoutsVisibilityForGuarantor') )
{
    my @relatives =
      Koha::Database->new()->schema()->resultset("Borrower")->search(
        {
            privacy_guarantor_checkouts => 1,
            'me.guarantorid'           => $borrowernumber
        },
        { prefetch => [ { 'issues' => { 'item' => 'biblio' } } ] }
      );
    $template->param( relatives => \@relatives );
}

$template->param(
    borrower                 => $borr,
    patron_messages          => $patron_messages,
    patronupdate             => $patronupdate,
    OpacRenewalAllowed       => C4::Context->preference("OpacRenewalAllowed"),
    userview                 => 1,
    SuspendHoldsOpac         => C4::Context->preference('SuspendHoldsOpac'),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
    OpacHoldNotes            => C4::Context->preference('OpacHoldNotes'),
    failed_holds             => scalar $query->param('failed_holds'),
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
