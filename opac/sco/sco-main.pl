#!/usr/bin/perl
#
# This code has been modified by Trendsetters (originally from opac-user.pl)
# This code has been modified by rch
# Parts Copyright 2010-2011, ByWater Solutions (those related to username/password auth)
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

# We're going to authenticate a self-check user.  we'll add a flag to borrowers 'selfcheck'
#
# We're in a controlled environment; we trust the user.
# So the selfcheck station will accept a patronid and issue items to that borrower.
# FIXME: NOT really a controlled environment...  We're on the internet!
#
# The checkout permission comes form the CGI cookie/session of a staff user.
# The patron is not really logging in here in the same way as they do on the
# rest of the OPAC.  So don't confuse loggedinuser with the patron user.
#
# FIXME: inputfocus not really used in TMPL

use strict;
use warnings;

use CGI;
use Digest::MD5 qw(md5_base64);

use C4::Auth qw(get_template_and_user checkpw);
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Output;
use C4::Members;
use C4::Biblio;
use C4::Items;

my $query = new CGI;

unless (C4::Context->preference('WebBasedSelfCheck')) {
    # redirect to OPAC home if self-check is not enabled
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

if (C4::Context->preference('AutoSelfCheckAllowed')) 
{
    my $AutoSelfCheckID = C4::Context->preference('AutoSelfCheckID');
    my $AutoSelfCheckPass = C4::Context->preference('AutoSelfCheckPass');
    $query->param(-name=>'userid',-values=>[$AutoSelfCheckID]);
    $query->param(-name=>'password',-values=>[$AutoSelfCheckPass]);
    $query->param(-name=>'koha_login_context',-values=>['sco']);
}
my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => "sco/sco-main.tt",
    authnotrequired => 0,
    flagsrequired => { circulate => "circulate_remaining_permissions" },
    query => $query,
    type  => "opac",
    debug => 1,
});
if (C4::Context->preference('SelfCheckoutByLogin'))
{
    $template->param(authbylogin  => 1);
}

# Get the self checkout timeout preference, or use 120 seconds as a default
my $selfchecktimeout = 120000;
if (C4::Context->preference('SelfCheckTimeout')) { 
    $selfchecktimeout = C4::Context->preference('SelfCheckTimeout') * 1000;
}
$template->param(SelfCheckTimeout => $selfchecktimeout);

# Checks policy laid out by AllowSelfCheckReturns, defaults to 'on' if preference is undefined
my $allowselfcheckreturns = 1;
if (defined C4::Context->preference('AllowSelfCheckReturns')) {
    $allowselfcheckreturns = C4::Context->preference('AllowSelfCheckReturns');
}
$template->param(AllowSelfCheckReturns => $allowselfcheckreturns);


my $issuerid = $loggedinuser;
my ($op, $patronid, $patronlogin, $patronpw, $barcode, $confirmed) = (
    $query->param("op")         || '',
    $query->param("patronid")   || '',
    $query->param("patronlogin")|| '',
    $query->param("patronpw")   || '',
    $query->param("barcode")    || '',
    $query->param("confirmed")  || '',
);

my $issuenoconfirm = 1; #don't need to confirm on issue.
#warn "issuerid: " . $issuerid;
my $issuer   = GetMemberDetails($issuerid);
my $item     = GetItem(undef,$barcode);
if (C4::Context->preference('SelfCheckoutByLogin') && !$patronid) {
    my $dbh = C4::Context->dbh;
    my $resval;
    ($resval, $patronid) = checkpw($dbh, $patronlogin, $patronpw);
}
my $borrower = GetMemberDetails(undef,$patronid);

my $currencySymbol = "";
if ( defined C4::Budgets->GetCurrency() ) {
    $currencySymbol = C4::Budgets->GetCurrency()->{symbol};
}

my $branch = $issuer->{branchcode};
my $confirm_required = 0;
my $return_only = 0;
#warn "issuer cardnumber: " .   $issuer->{cardnumber};
#warn "patron cardnumber: " . $borrower->{cardnumber};
if ($op eq "logout") {
    $query->param( patronid => undef, patronlogin => undef, patronpw => undef );
}
elsif ( $op eq "returnbook" && $allowselfcheckreturns ) {
    my ($doreturn) = AddReturn( $barcode, $branch );
    #warn "returnbook: " . $doreturn;
    $borrower = GetMemberDetails(undef,$patronid);
}
elsif ( $op eq "checkout" ) {
    my $impossible  = {};
    my $needconfirm = {};
    if ( !$confirmed ) {
        ( $impossible, $needconfirm ) = CanBookBeIssued(
            $borrower,
            $barcode,
            undef,
            0,
            C4::Context->preference("AllowItemsOnHoldCheckout")
        );
    }
    $confirm_required = scalar keys %$needconfirm;

    #warn "confirm_required: " . $confirm_required ;
    if (scalar keys %$impossible) {

        #  warn "impossible: numkeys: " . scalar (keys(%$impossible));
        #warn join " ", keys %$impossible;
        my $issue_error = (keys %$impossible)[0];

        # FIXME  we assume only one error.
        $template->param(
            impossible                => $issue_error,
            "circ_error_$issue_error" => 1,
            title                     => $item->{title},
            hide_main                 => 1,
        );
        if ($issue_error eq 'DEBT') {
            $template->param(amount => $currencySymbol.$impossible->{DEBT});
        }
        #warn "issue_error: " . $issue_error ;
        if ( $issue_error eq "NO_MORE_RENEWALS" ) {
            $return_only = 1;
            $template->param(
                returnitem => 1,
                barcode    => $barcode,
            );
        }
    } elsif ( $needconfirm->{RENEW_ISSUE} ) {
        if ($confirmed) {
            #warn "renewing";
            AddRenewal( $borrower, $item->{itemnumber} );
        } else {
            #warn "renew confirmation";
            $template->param(
                renew               => 1,
                barcode             => $barcode,
                confirm             => 1,
                confirm_renew_issue => 1,
                hide_main           => 1,
            );
        }
    } elsif ( $confirm_required && !$confirmed ) {
        #warn "failed confirmation";
        my $issue_error = (keys %$needconfirm)[0];
        $template->param(
            impossible                => (keys %$needconfirm)[0],
            "circ_error_$issue_error" => 1,
            hide_main                 => 1,
        );
        if ($issue_error eq 'DEBT') {
            $template->param(amount => $currencySymbol.$needconfirm->{DEBT});
        }
    } else {
        if ( $confirmed || $issuenoconfirm ) {    # we'll want to call getpatroninfo again to get updated issues.
            # warn "issuing book?";
            AddIssue( $borrower, $barcode );
            # ($borrower, $flags) = getpatroninformation(undef,undef, $patronid);
            # $template->param(
            #   patronid => $patronid,
            #   validuser => 1,
            # );
        } else {
            $confirm_required = 1;
            #warn "issue confirmation";
            $template->param(
                confirm    => "Issuing title: " . $item->{title},
                barcode    => $barcode,
                hide_main  => 1,
                inputfocus => 'confirm',
            );
        }
    }
} # $op

if ($borrower->{cardnumber}) {
#   warn "issuer's  branchcode: " .   $issuer->{branchcode};
#   warn   "user's  branchcode: " . $borrower->{branchcode};
    my $borrowername = sprintf "%s %s", ($borrower->{firstname} || ''), ($borrower->{surname} || '');
    my @issues;
    my ($issueslist) = GetPendingIssues( $borrower->{'borrowernumber'} );
    foreach my $it (@$issueslist) {
        my ($renewokay, $renewerror) = CanBookBeIssued(
            $borrower,
            $it->{'barcode'},
            undef,
            0,
            C4::Context->preference("AllowItemsOnHoldCheckout")
        );
        $it->{'norenew'} = 1 if $renewokay->{'NO_MORE_RENEWALS'};
        push @issues, $it;
    }

    $template->param(
        validuser => 1,
        borrowername => $borrowername,
        issues_count => scalar(@issues),
        ISSUES => \@issues,
        patronid => $patronid,
        patronlogin => $patronlogin,
        patronpw => $patronpw,
        noitemlinks => 1 ,
        borrowernumber => $borrower->{'borrowernumber'},
    );
    my $inputfocus = ($return_only      == 1) ? 'returnbook' :
                     ($confirm_required == 1) ? 'confirm'    : 'barcode' ;
    $template->param(
        inputfocus => $inputfocus,
        nofines => 1,

    );
    if (C4::Context->preference('ShowPatronImageInWebBasedSelfCheck')) {
        my ($image, $dberror) = GetPatronImage($borrower->{borrowernumber});
        if ($image) {
            $template->param(
                display_patron_image => 1,
                cardnumber           => $borrower->{cardnumber},
            );
        }
    }
} else {
    $template->param(
        patronid   => $patronid,
        nouser     => $patronid,
    );
}

$template->param(
    SCOUserJS  => C4::Context->preference('SCOUserJS'),
    SCOUserCSS => C4::Context->preference('SCOUserCSS'),
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
