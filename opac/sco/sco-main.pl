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
# We're not in a controlled environment; we never trust the user.
#
# The checkout permission comes form the CGI cookie/session of a staff user.
# The patron is not really logging in here in the same way as they do on the
# rest of the OPAC.  So don't confuse loggedinuser with the patron user.
# The patron id/cardnumber is retrieved from the JWT

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth        qw( in_iprange get_template_and_user checkpw );
use C4::Circulation qw( barcodedecode AddReturn CanBookBeIssued AddIssue CanBookBeRenewed AddRenewal );
use C4::Reserves;
use C4::Output qw( output_html_with_http_headers );
use C4::Members;
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Currencies;
use Koha::Items;
use Koha::Patrons;
use Koha::Patron::Images;
use Koha::Patron::Messages;
use Koha::Plugins;
use Koha::Token;
use Koha::CookieManager;

my $query = CGI->new;

unless ( C4::Context->preference('WebBasedSelfCheck') ) {

    # redirect to OPAC home if self-check is not enabled
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

unless ( in_iprange( C4::Context->preference('SelfCheckAllowByIPRanges') ) ) {

    # redirect to OPAC home if self-checkout not permitted from current IP
    print $query->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

$query->param( -name => 'sco_user_login', -values => [1] );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "sco/sco-main.tt",
        flagsrequired => { self_check => "self_checkout_module" },
        query         => $query,
        type          => "opac",
    }
);

# Get the self checkout timeout preference, or use 120 seconds as a default
my $selfchecktimeout = 120000;
if ( C4::Context->preference('SelfCheckTimeout') ) {
    $selfchecktimeout = C4::Context->preference('SelfCheckTimeout') * 1000;
}
$template->param( SelfCheckTimeout => $selfchecktimeout );

# Checks policy laid out by SCOAllowCheckin, defaults to 'on' if preference is undefined
my $allowselfcheckreturns = 1;
if ( defined C4::Context->preference('SCOAllowCheckin') ) {
    $allowselfcheckreturns = C4::Context->preference('SCOAllowCheckin');
}

my $issuerid = $loggedinuser;
my ( $op, $patronlogin, $patronpw, $barcodestr, $confirmed, $newissues, $load_checkouts ) = (
    $query->param("op")             || '',
    $query->param("patronlogin")    || '',
    $query->param("patronpw")       || '',
    $query->param("barcode")        || '',
    $query->param("confirmed")      || '',
    $query->param("newissues")      || '',
    $query->param("load_checkouts") || '',
);

my $jwt = $query->cookie('JWT');

#FIXME: This needs to be changed to a POSTed logout...
if ( $op eq "logout" ) {
    $template->param( loggedout => 1 );
    $query->param( patronlogin => undef, patronpw => undef );
    undef $jwt;
}

my $barcodes = [];
if ($barcodestr) {
    push @$barcodes, split( /\s\n/, $barcodestr );
    $barcodes = [ map { $_ =~ /^\s*$/ ? () : barcodedecode($_) } @$barcodes ];
}

my @newissueslist  = split /,/, $newissues;
my $issuenoconfirm = 1;                                           #don't need to confirm on issue.
my $issuer         = Koha::Patrons->find($issuerid)->unblessed;

my $patronid = $jwt ? Koha::Token->new->decode_jwt( { token => $jwt } ) : undef;
unless ($patronid) {
    if ( C4::Context->preference('SelfCheckoutByLogin') ) {
        ( undef, $patronid ) = checkpw( $patronlogin, $patronpw );
    } else {    # People should not do that unless they know what they are doing!
                # SelfCheckAllowByIPRanges MUST be configured
        $patronid = $query->param('patronid');
    }
    $jwt = Koha::Token->new->generate_jwt( { id => $patronid } ) if $patronid;
}

my $patron;
my $anonymous_patron = C4::Context->preference('AnonymousPatron');
if ($patronid) {
    Koha::Plugins->call( 'patron_barcode_transform', \$patronid );
    $patron = Koha::Patrons->find( { cardnumber => $patronid } );

    # redirect to OPAC home if user is trying to log in as the anonymous patron
    if ( $patron && ( $patron->borrowernumber eq $anonymous_patron ) ) {
        print $query->redirect("/cgi-bin/koha/opac-main.pl");
        exit;
    }
}

undef $jwt unless $patron;

my $branch           = $issuer->{branchcode};
my $confirm_required = 0;
my $return_only      = 0;

my $batch_checkouts_allowed;
if ($patron) {
    my @batch_category_codes = split ',', C4::Context->preference('SCOBatchCheckoutsValidCategories');
    my $categorycode         = $patron->categorycode;
    if ( $categorycode && grep { $_ eq $categorycode } @batch_category_codes ) {
        $batch_checkouts_allowed = 1;
    }
}

if ( $patron && $op eq "cud-returnbook" && $allowselfcheckreturns ) {
    my $success = 1;

    foreach my $barcode (@$barcodes) {
        my $item = Koha::Items->find( { barcode => $barcode } );
        if ( $success && C4::Context->preference("CircConfirmItemParts") ) {
            if ( defined($item)
                && $item->materials )
            {
                $success = 0;
            }
        }

        if ($success) {

            # Patron cannot checkin an item they don't own
            $success = 0
                unless $patron->checkouts->find( { itemnumber => $item->itemnumber } );
        }

        if ($success) {
            ($success) = AddReturn( $barcode, $branch );
        }

        $template->param(
            returned => $success,
            barcode  => $barcode
        );
    }    # foreach barcode in barcodes

} elsif ( $patron && ( $op eq 'cud-checkout' ) ) {
    my @failed_checkouts;
    my @confirm_checkouts;
    foreach my $barcode (@$barcodes) {
        my $item        = Koha::Items->find( { barcode => $barcode } );
        my $impossible  = {};
        my $needconfirm = {};
        ( $impossible, $needconfirm ) = CanBookBeIssued(
            $patron,
            $barcode,
            undef,
            0,
            C4::Context->preference("AllowItemsOnHoldCheckoutSCO")
        );
        my $issue_error;
        if ( $confirm_required = scalar keys %$needconfirm ) {
            for my $error (
                qw( UNKNOWN_BARCODE max_loans_allowed ISSUED_TO_ANOTHER NO_MORE_RENEWALS NOT_FOR_LOAN DEBT WTHDRAWN RESTRICTED RESERVED ITEMNOTSAMEBRANCH EXPIRED DEBARRED CARD_LOST GNA INVALID_DATE UNKNOWN_BARCODE TOO_MANY DEBT_GUARANTEES DEBT_GUARANTORS USERBLOCKEDOVERDUE PATRON_CANT PREVISSUE NOT_FOR_LOAN_FORCING ITEM_LOST ADDITIONAL_MATERIALS )
                )
            {
                if ( $needconfirm->{$error} ) {
                    $issue_error = $error;
                    $confirmed   = 0;
                    last;
                }
            }
        }

        if ( scalar keys %$impossible ) {
            my $issue_error =
                ( keys %$impossible )[0];    # FIXME This is wrong, we assume only one error and keys are not ordered
            my $title = ($item) ? $item->biblio->title : '';

            my $failed_checkout = {
                "circ_error_$issue_error" => 1,
                title                     => $title,
            };

            if ( $issue_error eq 'DEBT' ) {
                $failed_checkout->{DEBT} = $impossible->{DEBT};
            }
            if ( $issue_error eq "NO_MORE_RENEWALS" ) {
                $return_only                   = 1;
                $failed_checkout->{barcode}    = $barcode;
                $failed_checkout->{returnitem} = 1;
            }

            push @failed_checkouts, $failed_checkout;

            $template->param(
                hide_main => 1,
            );
        } elsif ( $needconfirm->{RENEW_ISSUE} ) {
            my $confirm_checkout = {
                renew               => 1,
                barcode             => $barcode,
                confirm             => $item->biblio->title,
                confirm_renew_issue => 1,
            };
            push @confirm_checkouts, $confirm_checkout;
            $template->param(
                hide_main => 1,
            );
        } elsif ( $confirm_required && !$confirmed ) {
            my $failed_checkout = {
                "circ_error_$issue_error" => 1,
            };
            if ( $issue_error eq 'DEBT' ) {
                $failed_checkout->{DEBT} = $needconfirm->{DEBT};
            }
            push @failed_checkouts, $failed_checkout;
            $template->param(
                hide_main => 1,
            );
        } else {
            if ( $confirmed || $issuenoconfirm ) {    # we'll want to call getpatroninfo again to get updated issues.
                my ( $hold_existed, $item );
                if ( C4::Context->preference('HoldFeeMode') eq 'any_time_is_collected' ) {

                    # There is no easy way to know if the patron has been charged for this item.
                    # So we check if a hold existed for this item before the check in
                    $item         = Koha::Items->find( { barcode => $barcode } );
                    $hold_existed = Koha::Holds->search(
                        {
                            -and => {
                                borrowernumber => $patron->borrowernumber,
                                -or            => {
                                    biblionumber => $item->biblionumber,
                                    itemnumber   => $item->itemnumber
                                }
                            }
                        }
                    )->count;
                }

                my $new_issue = AddIssue( $patron, $barcode );
                $template->param( issued => 1, new_issue => $new_issue );
                push @newissueslist, $barcode unless ( grep /^$barcode$/, @newissueslist );

                if ($hold_existed) {
                    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
                    $template->param(

                        # If the hold existed before the check in, let's confirm that the charge line exists
                        # Note that this should not be needed but since we do not have proper exception handling here we do it this way
                        patron_has_hold_fee => Koha::Account::Lines->search(
                            {
                                borrowernumber  => $patron->borrowernumber,
                                debit_type_code => 'RESERVE',
                                description     => $item->biblio->title,
                                date            => $dtf->format_date(dt_from_string)
                            }
                        )->count,
                    );
                }
            } else {
                $confirm_required = 1;
                my $confirm_checkout = {
                    confirm => "Issuing title: " . $item->biblio->title,
                    barcode => $barcode,
                };
                push @confirm_checkouts, $confirm_checkout;
                $template->param(
                    hide_main => 1,
                );
            }
        }
    }    # foreach barcode in barcodes

    $template->param(
        impossible => \@failed_checkouts,
        confirm    => \@confirm_checkouts,
    );
}    # $op

if ( $patron && ( $op eq 'cud-renew' ) ) {
    foreach my $barcode (@$barcodes) {
        my $item = Koha::Items->find( { barcode => $barcode } );

        if ( $patron->checkouts->find( { itemnumber => $item->itemnumber } ) ) {
            my ( $status, $renewerror ) = CanBookBeRenewed( $patron, $item->checkout );
            if ($status) {
                AddRenewal(
                    {
                        borrowernumber => $patron->borrowernumber,
                        itemnumber     => $item->itemnumber,
                        seen           => 1
                    }
                );
                push @newissueslist, $barcode;
                $template->param(
                    renewed => 1,
                    barcode => $barcode
                );
            }
        } else {
            $template->param( renewed => 0 );
        }
    }    # foreach barcode in barcodes
}

if ($patron) {
    my $borrowername = sprintf "%s %s", ( $patron->firstname || '' ), ( $patron->surname || '' );
    my @checkouts;
    my $pending_checkouts = $patron->pending_checkouts;
    if ( C4::Context->preference('SCOLoadCheckoutsByDefault') || $load_checkouts ) {
        while ( my $c = $pending_checkouts->next ) {
            my $checkout = $c->unblessed_all_relateds;
            my ( $can_be_renewed, $renew_error ) = CanBookBeRenewed( $patron, $c );
            $checkout->{can_be_renewed} = $can_be_renewed;    # In the future this will be $checkout->can_be_renewed
            $checkout->{renew_error}    = $renew_error;
            $checkout->{overdue}        = $c->is_overdue;
            push @checkouts, $checkout;
        }
    }

    my $show_priority;
    for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
        m/priority/ and $show_priority = 1;
    }

    my $account      = $patron->account;
    my $total        = $account->balance;
    my $accountlines = $account->lines;

    my $holds               = $patron->holds;
    my $waiting_holds_count = 0;

    while ( my $hold = $holds->next ) {
        $waiting_holds_count++ if $hold->is_waiting;
    }

    $template->param(
        validuser                => 1,
        borrowername             => $borrowername,
        issues_count             => scalar(@checkouts) || $pending_checkouts->count(),
        ISSUES                   => \@checkouts,
        HOLDS                    => $holds,
        newissues                => join( ',', @newissueslist ),
        patronlogin              => $patronlogin,
        patronpw                 => $patronpw,
        waiting_holds_count      => $waiting_holds_count,
        noitemlinks              => 1,
        load_checkouts           => $load_checkouts,
        borrowernumber           => $patron->borrowernumber,
        SuspendHoldsOpac         => C4::Context->preference('SuspendHoldsOpac'),
        AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
        howpriority              => $show_priority,
        ACCOUNT_LINES            => $accountlines,
        total                    => $total,
        batch_checkouts_allowed  => $batch_checkouts_allowed,
    );

    my $patron_messages = Koha::Patron::Messages->search(
        {
            borrowernumber => $patron->borrowernumber,
            message_type   => 'B',
        }
    );
    $template->param(
        patron_messages => $patron_messages,
        opacnote        => $patron->opacnote,
    );

    $template->param(
        nofines => 1,

    );
    if ( C4::Context->preference('ShowPatronImageInWebBasedSelfCheck') ) {
        my $patron_image = $patron->image;
        $template->param(
            display_patron_image => 1,
        ) if $patron_image;
    }
} else {
    $template->param(
        nouser => $patronid,
    );
}
my $cookie_mgr = Koha::CookieManager->new;
$cookie = $cookie_mgr->replace_in_list(
    $cookie,
    $query->cookie(
        -name     => 'JWT',
        -value    => $jwt // '',
        -expires  => $jwt ? '+1d' : '',
        -HttpOnly => 1,
        -secure   => ( C4::Context->https_enabled() ? 1 : 0 ),
        -sameSite => 'Lax'
    )
);
$template->param( patronid => $patronid );

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
