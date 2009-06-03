#!/usr/bin/perl
#
# This code has been modified by Trendsetters (originally from opac-user.pl)
# This code has been modified by rch
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

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Output;
use C4::Members;
use C4::Dates;
use C4::Biblio;
use C4::Items;

my $query = new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => "sco/sco-main.tmpl",
    authnotrequired => 0,
      flagsrequired => { circulate => "circulate_remaining_permissions" },
    query => $query,
    type  => "opac",
    debug => 1,
});

my $issuerid = $loggedinuser;
my ($op, $patronid, $barcode, $confirmed, $timedout) = (
    $query->param("op")         || '',
    $query->param("patronid")   || '',
    $query->param("barcode")    || '',
    $query->param("confirmed")  || '',
    $query->param("timedout")   || '', #not actually using this...
);

my %confirmation_strings = ( RENEW_ISSUE => "This item is already checked out to you.  Return it?", );
my $issuenoconfirm = 1; #don't need to confirm on issue.
#warn "issuerid: " . $issuerid;
my $issuer   = GetMemberDetails($issuerid);
my $item     = GetItem(undef,$barcode);
my $borrower = GetMemberDetails(undef,$patronid);

my $branch = $issuer->{branchcode};
my $confirm_required = 0;
my $return_only = 0;
#warn "issuer cardnumber: " .   $issuer->{cardnumber};
#warn "patron cardnumber: " . $borrower->{cardnumber};
if ($op eq "logout") {
    $query->param( patronid => undef );
}
elsif ( $op eq "returnbook" ) {
    my ($doreturn) = AddReturn( $barcode, $branch );
    #warn "returnbook: " . $doreturn;
    $borrower = GetMemberDetails( undef, $patronid );   # update borrower
}
elsif ( $op eq "checkout" ) {
    my $impossible  = {};
    my $needconfirm = {};
    if ( !$confirmed ) {
        ( $impossible, $needconfirm ) = CanBookBeIssued( $borrower, $barcode );
    }
    $confirm_required = scalar keys %$needconfirm;

    #warn "confirm_required: " . $confirm_required ;
    if (scalar keys %$impossible) {

        #  warn "impossible: numkeys: " . scalar (keys(%$impossible));
        warn join " ", keys %$impossible;
        my $issue_error = (keys %$impossible)[0];

        # FIXME  we assume only one error.
        $template->param(
            impossible => $issue_error,
            title      => $item->{title},
            hide_main  => 1,
        );
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
        $template->param(
            impossible => (keys %$needconfirm)[0],
            hide_main  => 1,
        );
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
        my ($renewokay, $renewerror) = CanBookBeIssued($borrower, $it->{'barcode'},'','');
        $it->{'norenew'} = 1 if $renewokay->{'NO_MORE_RENEWALS'} == 1;
        push @issues, $it;
    }

    $template->param(
        validuser => 1,
        borrowername => $borrowername,
        issues_count => scalar(@issues),
        ISSUES => \@issues,
        patronid => $patronid,
        noitemlinks => 1 ,
    );
    my $inputfocus = ($return_only      == 1) ? 'returnbook' :
                     ($confirm_required == 1) ? 'confirm'    : 'barcode' ;
    $template->param(
        inputfocus => $inputfocus,
		nofines => 1,
    );
} else {
    $template->param(
        patronid   => $patronid,
        nouser     => $patronid,
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
