
#!/usr/bin/perl
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


use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw(get_template_and_user checkpw);
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Output;
use C4::Members;
use C4::Biblio;
use C4::Items;
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Currencies;
use Koha::Patron::Images;
use Koha::Patron::Messages;
use Koha::Token;
use Koha::Calendar;


my $query = new CGI;
my $messages;
my $borrower;


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
$query->param(-name=>'sco_user_login',-values=>[1]);
my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name   => "sco/sco-main.tt",
    authnotrequired => 0,
    flagsrequired => { circulate => "self_checkout" },
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
my ($op, $patronid, $patronlogin, $patronpw, $barcode, $confirmed, $uibarcode,$checkinmessage,
    $reserve_id) = (
    $query->param("op")         || '',
    $query->param("patronid")   || '',
    $query->param("patronlogin")|| '',
    $query->param("patronpw")   || '',
    $query->param("barcode")    || '',
    $query->param("confirmed")  || '',
    $query->param("uibarcode")  || '',
    $query->param("checkinmessage") || '',
    $query->param("reserve_id") || '',
);


my $issuenoconfirm = 1; #don't need to confirm on issue.
#warn "issuerid: " . $issuerid;
my $issuer   = GetMember( borrowernumber => $issuerid );
my $item     = GetItem(undef,$barcode);
$checkinmessage = undef;
my $checkinitem;
my $checkinbranchcode;
my $userenv = C4::Context->userenv;
my $userenv_branch = $userenv->{'branch'} // '';
my $calendar    = Koha::Calendar->new( branchcode => $userenv_branch );
my $today       = DateTime->now( time_zone => C4::Context->tz());
my $dropboxdate = $calendar->addDate($today, -1);
#my $returndate = $calendar->addDate($today);
my $biblio;

#message to screen if returned without log in (checkinmessage)
if ($uibarcode) {
    $checkinitem = GetItem(undef,$uibarcode);
    my $checkinmember = GetMember( borrowernumber => $loggedinuser);
    if ($checkinitem) {
       $biblio = GetBiblioData($checkinitem->{biblionumber});
       if ($biblio) {
           $checkinmessage = "Returned ".$biblio->{title};
       }
       if ($checkinmember) {
          $checkinbranchcode = $checkinmember->{branchcode};

          #home branch of item
          if ($checkinbranchcode) {
             my $tmpdbh = C4::Context->dbh;
             my $tmpsth = $tmpdbh->prepare("select branchname from branches where branchcode = ? ");
             $tmpsth->execute($checkinbranchcode);
              while (my @row=$tmpsth->fetchrow_array()) {
                  $checkinmessage.=", ".$row[0];    
              }
          }
       }
    }
    else {
        $checkinmessage = "Item not found"; 
    }
} 

if (C4::Context->preference('SelfCheckoutByLogin') && !$patronid) {
    my $dbh = C4::Context->dbh;
    my $resval;
    ($resval, $patronid) = checkpw($dbh, $patronlogin, $patronpw);
}
$borrower = GetMember( cardnumber => $patronid );

my $currencySymbol = "";
if ( my $active_currency = Koha::Acquisition::Currencies->get_active ) {
    $currencySymbol = $active_currency->symbol;
}

my $branch = $issuer->{branchcode};

my $confirm_required = 0;
my $return_only = 0;
#warn "issuer cardnumber: " .   $issuer->{cardnumber};
#warn "patron cardnumber: " . $borrower->{cardnumber};
if ($op eq "logout") {
    $query->param( patronid => undef, patronlogin => undef, patronpw => undef );
}

#if returned
elsif (($op eq "checkin") || ($op eq "returnbook" && $allowselfcheckreturns)) {
    
    $checkinitem = GetItem(undef,$uibarcode);
    my $tobranch = $checkinitem->{'homebranch'};

    $biblio = GetBiblioData($checkinitem->{biblionumber});
    my ($doreturn,$messages,$issueinformation,$borrower) = AddReturn($uibarcode,$branch,undef,1,$today,$dropboxdate);
    my $needstransfer = $messages->{'NeedsTransfer'};
    my $settransit=0;
    if($messages->{'ResFound'}) {
        my $reserve = $messages->{'ResFound'};
        my $reserve_id = $reserve->{'reserve_id'};
        my $resborrower = $reserve->{'borrowernumber'};
        my $diffBranchReturned = $reserve->{'branchcode'};
        my $itemnumber = $checkinitem->{'itemnumber'};
        my $diffBranchSend = ($branch ne $diffBranchReturned) ? $diffBranchReturned : undef;
        my $iteminfo   = GetBiblioFromItemNumber($itemnumber);

        if($diffBranchSend) {
            ModReserveAffect( $itemnumber, $resborrower, $diffBranchSend, $reserve_id);
            ModItemTransfer($itemnumber,$branch,$diffBranchReturned);         
        }
        else {
            $settransit = C4::Context->preference('RequireSCCheckInBeforeNotifyingPickups');
            $settransit = 0 unless $settransit;

            ModReserveAffect( $itemnumber, $resborrower, $settransit, $reserve_id);
        }
        $borrower = GetMember( cardnumber => $patronid );
    }
    else {
         if($needstransfer) {
             ModItemTransfer($checkinitem->{'itemnumber'}, $branch, $tobranch);
         }
    }

    if($messages->{'WrongTransfer'}) {
       updateWrongTransfer ($checkinitem->{'itemnumber'},$tobranch,$branch);
    }
    
    if ($checkinmessage) {
        $template->param(checkinmessage => $checkinmessage);
    }
    else {
        $template->param(checkinmessage => undef);
    }

    #don't show returns long
    $template->param(SelfCheckTimeout => 10000);
    $template->param(uibarcode => $uibarcode); 
}
elsif ( $op eq "checkout" ) {
    my $impossible  = {};
    my $needconfirm = {};

    ( $impossible, $needconfirm ) = CanBookBeIssued(
        $borrower,
        $barcode,
        undef,
        0,
        C4::Context->preference("AllowItemsOnHoldCheckoutSCO")
    );
    my $issue_error;
    if ( $confirm_required = scalar keys %$needconfirm ) {
        for my $error ( qw( UNKNOWN_BARCODE max_loans_allowed ISSUED_TO_ANOTHER NO_MORE_RENEWALS NOT_FOR_LOAN DEBT WTHDRAWN RESTRICTED RESERVED ITEMNOTSAMEBRANCH EXPIRED DEBARRED CARD_LOST GNA INVALID_DATE UNKNOWN_BARCODE TOO_MANY DEBT_GUARANTEES USERBLOCKEDOVERDUE PATRON_CANT PREVISSUE NOT_FOR_LOAN_FORCING ITEM_LOST) ) {
            if ( $needconfirm->{$error} ) {
                $issue_error = $error;
                $confirmed = 0;
                last;
            }
        }
    }

    #warn "confirm_required: " . $confirm_required ;
    if (scalar keys %$impossible) {

        my $issue_error = (keys %$impossible)[0]; # FIXME This is wrong, we assume only one error and keys are not ordered

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
            AddRenewal( $borrower->{borrowernumber}, $item->{itemnumber} );
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
            impossible                => 1,
            "circ_error_$issue_error" => 1,
            hide_main                 => 1,
        );
        if ($issue_error eq 'DEBT') {
            $template->param(amount => $currencySymbol.$needconfirm->{DEBT});
        }
    } else {
        if ( $confirmed || $issuenoconfirm ) {    # we'll want to call getpatroninfo again to get updated issues.
            my ( $hold_existed, $item );
            if ( C4::Context->preference('HoldFeeMode') eq 'any_time_is_collected' ) {
                # There is no easy way to know if the patron has been charged for this item.
                # So we check if a hold existed for this item before the check in
                $item = Koha::Items->find({ barcode => $barcode });
                $hold_existed = Koha::Holds->search(
                    {
                        -and => {
                            borrowernumber => $borrower->{borrowernumber},
                            -or            => {
                                biblionumber => $item->biblionumber,
                                itemnumber   => $item->itemnumber
                            }
                        }
                    }
                )->count;
            }
            AddIssue( $borrower, $barcode );

            if ( $hold_existed ) {
                my $dtf = Koha::Database->new->schema->storage->datetime_parser;
                $template->param(
                    # If the hold existed before the check in, let's confirm that the charge line exists
                    # Note that this should not be needed but since we do not have proper exception handling here we do it this way
                    patron_has_hold_fee => Koha::Account::Lines->search(
                        {
                            borrowernumber => $borrower->{borrowernumber},
                            accounttype    => 'Res',
                            description    => 'Reserve Charge - ' . $item->biblio->title,
                            date           => $dtf->format_date(dt_from_string)
                        }
                      )->count,
                );
            }
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
        my ($can_be_renewed, $renew_error) = CanBookBeRenewed(
            $borrower->{borrowernumber},
            $it->{itemnumber},
        );
        $it->{can_be_renewed} = $can_be_renewed;
        $it->{renew_error} = $renew_error;
        $it->{date_due}  = $it->{date_due_sql};
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

    my $patron_messages = Koha::Patron::Messages->search(
        {
            borrowernumber => $borrower->{'borrowernumber'},
            message_type => 'B',
        }
    );
    $template->param(
        patron_messages => $patron_messages,
        opacnote => $borrower->{opacnote},
    );

    my $inputfocus = ($return_only      == 1) ? 'returnbook' :
                     ($confirm_required == 1) ? 'confirm'    : 'barcode' ;
    $template->param(
        inputfocus => $inputfocus,
        nofines => 1,

    );
    if (C4::Context->preference('ShowPatronImageInWebBasedSelfCheck')) {
        my $patron_image = Koha::Patron::Images->find($borrower->{borrowernumber});
        $template->param(
            display_patron_image => 1,
            cardnumber           => $borrower->{cardnumber},
            csrf_token           => Koha::Token->new->generate_csrf( { session_id => scalar $query->cookie('CGISESSID') . $borrower->{cardnumber}, id => $borrower->{userid}} ),
        ) if $patron_image;
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
