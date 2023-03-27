#!/usr/bin/perl

# script to execute issuing of books

# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
# Copyright 2011 PTFS-Europe Ltd.
# Copyright 2012 software.coop and MJ Ray
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

# FIXME There are too many calls to Koha::Patrons->find in this script

use Modern::Perl;
use CGI qw ( -utf8 );
use URI::Escape qw( uri_escape_utf8 );
use DateTime;
use DateTime::Duration;
use Scalar::Util qw( looks_like_number );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Auth qw( get_session get_template_and_user );
use C4::Koha;
use C4::Circulation qw( barcodedecode CanBookBeIssued AddIssue );
use C4::Members;
use C4::Biblio qw( TransformMarcToKoha );
use C4::Search qw( new_record_from_zebra );
use C4::Reserves;
use Koha::Holds;
use C4::Context;
use CGI::Session;
use Koha::AuthorisedValues;
use Koha::CsvProfiles;
use Koha::Patrons;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron::Restriction::Types;
use Koha::Plugins;
use Koha::Database;
use Koha::BiblioFrameworks;
use Koha::Items;
use Koha::SearchEngine;
use Koha::SearchEngine::Search;
use Koha::Patron::Modifications;
use Koha::Token;

use List::MoreUtils qw( uniq );

#
# PARAMETERS READING
#
my $query = CGI->new;

my $override_high_holds     = $query->param('override_high_holds');
my $override_high_holds_tmp = $query->param('override_high_holds_tmp');

my $sessionID = $query->cookie("CGISESSID") ;
my $session = get_session($sessionID);

my $barcodes = [];
my $barcode =  $query->param('barcode');
my $findborrower;
my $autoswitched;
my $borrowernumber = $query->param('borrowernumber');

if (C4::Context->preference("AutoSwitchPatron") && $barcode) {
    my $new_barcode = $barcode;
    Koha::Plugins->call( 'patron_barcode_transform', \$new_barcode );
    if (Koha::Patrons->search( { cardnumber => $new_barcode} )->count() > 0) {
        $findborrower = $barcode;
        undef $barcode;
        undef $borrowernumber;
        $autoswitched = 1;
    }
}
$findborrower ||= $query->param('findborrower') || q{};
$findborrower =~ s|,| |g;

# Barcode given by user could be '0'
if ( $barcode || ( defined($barcode) && $barcode eq '0' ) ) {
    $barcodes = [ $barcode ];
} else {
    my $filefh = $query->upload('uploadfile');
    if ( $filefh ) {
        while ( my $content = <$filefh> ) {
            $content =~ s/[\r\n]*$//g;
            push @$barcodes, $content if $content;
        }
    } elsif ( my $list = $query->param('barcodelist') ) {
        push @$barcodes, split( /\s\n/, $list );
        $barcodes = [ map { $_ =~ /^\s*$/ ? () : $_ } @$barcodes ];
    } else {
        @$barcodes = $query->multi_param('barcodes');
    }
}

$barcodes = [ uniq @$barcodes ];

my $template_name = q|circ/circulation.tt|;
my $patron = $borrowernumber ? Koha::Patrons->find( $borrowernumber ) : undef;
my $batch = $query->param('batch');
my $batch_allowed = 0;
if ( $batch && C4::Context->preference('BatchCheckouts') ) {
    $template_name = q|circ/circulation_batch_checkouts.tt|;
    my @batch_category_codes = split ',', C4::Context->preference('BatchCheckoutsValidCategories');
    my $categorycode = $patron->categorycode;
    if ( $categorycode && grep { $_ eq $categorycode } @batch_category_codes ) {
        $batch_allowed = 1;
    } else {
        $barcodes = [];
    }
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user (
    {
        template_name   => $template_name,
        query           => $query,
        type            => "intranet",
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
    }
);
my $logged_in_user = Koha::Patrons->find( $loggedinuser );

my $force_allow_issue = $query->param('forceallow') || 0;
if (!C4::Auth::haspermission( C4::Context->userenv->{id} , { circulate => 'force_checkout' } )) {
    $force_allow_issue = 0;
}
my $onsite_checkout = $query->param('onsite_checkout');

if (C4::Context->preference("OnSiteCheckoutAutoCheck") && $onsite_checkout eq "on") {
    $template->param(onsite_checkout => $onsite_checkout);
}

my @failedrenews = $query->multi_param('failedrenew');    # expected to be itemnumbers
our %renew_failed = ();
for (@failedrenews) { $renew_failed{$_} = 1; }

my @failedreturns = $query->multi_param('failedreturn');
our %return_failed = ();
for (@failedreturns) { $return_failed{$_} = 1; }

my $searchtype = $query->param('searchtype') || q{contain};

my $branch = C4::Context->userenv->{'branch'};

for my $barcode ( @$barcodes ) {
    $barcode = barcodedecode( $barcode ) if $barcode;
}

my $stickyduedate  = $query->param('stickyduedate') || $session->param('stickyduedate');
my $duedatespec    = $query->param('duedatespec')   || $session->param('stickyduedate');
my $restoreduedatespec  = $query->param('restoreduedatespec') || $duedatespec || $session->param('stickyduedate');
if ( $restoreduedatespec && $restoreduedatespec eq "highholds_empty" ) {
    undef $restoreduedatespec;
}
my $issueconfirmed = $query->param('issueconfirmed');
my $cancelreserve  = $query->param('cancelreserve');
my $cancel_recall  = $query->param('cancel_recall');
my $recall_id      = $query->param('recall_id');
my $debt_confirmed = $query->param('debt_confirmed') || 0; # Don't show the debt error dialog twice
my $charges        = $query->param('charges') || q{};

# Check if stickyduedate is turned off
if ( @$barcodes ) {
    # was stickyduedate loaded from session?
    if ( $stickyduedate && ! $query->param("stickyduedate") ) {
        $session->clear( 'stickyduedate' );
        $stickyduedate  = $query->param('stickyduedate');
        $duedatespec    = $query->param('duedatespec');
    }
    $session->param('auto_renew', scalar $query->param('auto_renew'));
}
else {
    $session->clear('auto_renew');
}

$template->param( auto_renew => $session->param('auto_renew') );

my ($datedue,$invalidduedate);

my $duedatespec_allow = C4::Context->preference('SpecifyDueDate');
if( $onsite_checkout && !$duedatespec_allow ) {
    $datedue = dt_from_string()->truncate(to => 'day');
    $datedue->set_hour(23);
    $datedue->set_minute(59);
} elsif( $duedatespec_allow ) {
    if ( $duedatespec ) {
        $datedue = eval { dt_from_string( $duedatespec ) };
        if (! $datedue ) {
            $invalidduedate = 1;
            $template->param( IMPOSSIBLE=>1, INVALID_DATE=>$duedatespec );
        }
    }
}

my $inprocess = (@$barcodes == 0) ? '' : $query->param('inprocess');
if ( @$barcodes == 0 && $charges eq 'yes' ) {
    $template->param(
        PAYCHARGES     => 'yes',
        borrowernumber => $borrowernumber
    );
}

#
# STEP 2 : FIND BORROWER
# if there is a list of find borrowers....
#
my $message;
if ($findborrower) {
    Koha::Plugins->call( 'patron_barcode_transform', \$findborrower );
    my $patron = Koha::Patrons->find( { cardnumber => $findborrower } );
    if ( $patron ) {
        $borrowernumber = $patron->borrowernumber;
    } else {
        print $query->redirect( "/cgi-bin/koha/members/member.pl?quicksearch=1&circsearch=1&searchmember=" . uri_escape_utf8($findborrower) );
        exit;
    }
}

# get the borrower information.....
my $balance = 0;
$patron ||= Koha::Patrons->find( $borrowernumber ) if $borrowernumber;
if ($patron) {

    $template->param( borrowernumber => $patron->borrowernumber );
    output_and_exit_if_error( $query, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

    my $overdues = $patron->overdues;
    my $issues = $patron->checkouts;
    $balance = $patron->account->balance;


    # if the expiry date is before today ie they have expired
    if ( $patron->is_expired ) {
        #borrowercard expired, no issues
        $template->param(
            noissues => ($force_allow_issue) ? 0 : "1",
            forceallow => $force_allow_issue,
            expired => "1",
        );
    }
    # check for NotifyBorrowerDeparture
    elsif ( $patron->is_going_to_expire ) {
        # borrower card soon to expire warn librarian
        $template->param( "warndeparture" => $patron->dateexpiry ,
                        );
        if (C4::Context->preference('ReturnBeforeExpiry')){
            $template->param("returnbeforeexpiry" => 1);
        }
    }
    $template->param(
        overduecount => $overdues->count,
        issuecount   => $issues->count,
        finetotal    => $balance,
    );

    if ( $patron and $patron->is_debarred ) {
        $template->param(
            'userdebarred'    => $patron->debarred,
            'debarredcomment' => $patron->debarredcomment,
            'debarredsince'   => $patron->restrictions->search()->single->created,
        );

        if ( $patron->debarred ne "9999-12-31" ) {
            $template->param( 'userdebarreddate' => $patron->debarred );
        }
    }

    # Calculate and display patron's age
    if ( !$patron->is_valid_age ) {
        $template->param( age_limitations => 1 );
        $template->param( age_low => $patron->category->dateofbirthrequired );
        $template->param( age_high => $patron->category->upperagelimit );
    }

}

#
# STEP 3 : ISSUING
#
#
if (@$barcodes) {
  my $checkout_infos;
  for my $barcode ( @$barcodes ) {

    my $template_params = {
        barcode         => $barcode,
        onsite_checkout => $onsite_checkout,
    };

    # always check for blockers on issuing
    my ( $error, $question, $alerts, $messages ) = CanBookBeIssued(
        $patron,
        $barcode, $datedue,
        $inprocess,
        undef,
        {
            onsite_checkout     => $onsite_checkout,
            override_high_holds => $override_high_holds || $override_high_holds_tmp || 0,
        }
    );

    my $blocker = $invalidduedate ? 1 : 0;

    $template_params->{alert} = $alerts;
    $template_params->{messages} = $messages;

    my $item = Koha::Items->find({ barcode => $barcode });

    my $biblio;
    if ( $item ) {
        $biblio = $item->biblio;
    }

    # Fix for bug 7494: optional checkout-time fallback search for a book

    if ( $error->{'UNKNOWN_BARCODE'}
        && C4::Context->preference("itemBarcodeFallbackSearch")
        && not $batch
    )
    {
     $template_params->{FALLBACK} = 1;

        my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
        my $query = "kw=" . $barcode;
        my ( $searcherror, $results, $total_hits ) = $searcher->simple_search_compat($query, 0, 10);

        # if multiple hits, offer options to librarian
        if ( $total_hits > 0 ) {
            my @barcodes;
            foreach my $hit ( @{$results} ) {
                my $chosen = # Maybe easier to retrieve the itemnumber from $hit?
                  TransformMarcToKoha({ record => C4::Search::new_record_from_zebra('biblioserver',$hit) });

                # offer all barcodes individually
                if ( $chosen->{barcode} ) {
                    push @barcodes, sort split(/\s*\|\s*/, $chosen->{barcode});
                }
            }
            my $items = Koha::Items->search({ barcode => {-in => \@barcodes}});
            $template_params->{options} = $items;
        }
    }

    # Only some errors will block when performing forced onsite checkout,
    # for other cases all errors will block
    my @blocking_error_codes = ($onsite_checkout and C4::Context->preference("OnSiteCheckoutsForce")) ?
        qw( UNKNOWN_BARCODE ) : (keys %$error);

    foreach my $code ( @blocking_error_codes ) {
        if ($error->{$code}) {
            $template_params->{$code} = $error->{$code};
            $template_params->{IMPOSSIBLE} = 1;
            $blocker = 1;
        }
    }

    delete $question->{'DEBT'} if ($debt_confirmed);

    if( $item and ( !$blocker or $force_allow_issue ) ){
        my $confirm_required = 0;
        unless($issueconfirmed){
            #  Get the item title for more information
            my $materials = $item->materials;
            my $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({ frameworkcode => $biblio->frameworkcode, kohafield => 'items.materials', authorised_value => $materials });
            $materials = $descriptions->{lib} // $materials;
            $template_params->{ADDITIONAL_MATERIALS} = $materials;
            $template_params->{itemhomebranch} = $item->homebranch;

            # pass needsconfirmation to template if issuing is possible and user hasn't yet confirmed.
            foreach my $needsconfirmation ( keys %$question ) {
                $template_params->{$needsconfirmation} = $$question{$needsconfirmation};
                $template_params->{getTitleMessageIteminfo} = $biblio->title;
                $template_params->{getBarcodeMessageIteminfo} = $item->barcode;
                $template_params->{NEEDSCONFIRMATION} = 1;
                $confirm_required = 1;
            }
        }
        unless($confirm_required) {
            my $switch_onsite_checkout = exists $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED};
            if ( C4::Context->preference('UseRecalls') && !$recall_id ) {
                my $recall = Koha::Recalls->find(
                    {
                        biblio_id => $item->biblionumber,
                        item_id   => [ undef, $item->itemnumber ],
                        status    => [ 'requested', 'waiting' ],
                        completed => 0,
                        patron_id => $patron->borrowernumber,
                    }
                );
                $recall_id = ( $recall and $recall->id ) ? $recall->id : undef;
            }
            my $issue = AddIssue( $patron->unblessed, $barcode, $datedue, $cancelreserve, undef, undef, { onsite_checkout => $onsite_checkout, auto_renew => $session->param('auto_renew'), switch_onsite_checkout => $switch_onsite_checkout, cancel_recall => $cancel_recall, recall_id => $recall_id, } );
            $template_params->{issue} = $issue;
            $session->clear('auto_renew');
            $inprocess = 1;
        }
    }

    if ($question->{RESERVE_WAITING} or $question->{RESERVED} or $question->{TRANSFERRED} or $question->{PROCESSING}){
        $template->param(
            reserveborrowernumber => $question->{'resborrowernumber'},
            reserve_id => $question->{reserve_id},
        );
    }


    # FIXME If the issue is confirmed, we launch another time checkouts->count, now display the issue count after issue
    $patron = Koha::Patrons->find( $borrowernumber );
    $template_params->{issuecount} = $patron->checkouts->count;

    if ( $item ) {
        $template_params->{item} = $item;
        $template_params->{biblio} = $biblio;
        $template_params->{itembiblionumber} = $biblio->biblionumber;
    }
    push @$checkout_infos, $template_params;
  }
  unless ( $batch ) {
    $template->param( %{$checkout_infos->[0]} );
    $template->param( barcode => $barcodes->[0] );
  } else {
    my $confirmation_needed = grep { $_->{NEEDSCONFIRMATION} } @$checkout_infos;
    $template->param(
        checkout_infos => $checkout_infos,
        confirmation_needed => $confirmation_needed,
    );
  }
}

##################################################################################
# BUILD HTML
# show all reserves of this borrower, and the position of the reservation ....
if ($patron) {
    my $holds = Koha::Holds->search( { borrowernumber => $borrowernumber } ); # FIXME must be Koha::Patron->holds
    my $waiting_holds = $holds->waiting;
    $template->param(
        holds_count  => $holds->count(),
        WaitingHolds => $waiting_holds,
    );

    if ( C4::Context->preference('UseRecalls') ) {
        my $waiting_recalls = $patron->recalls->search({ status => 'waiting' });
        $template->param(
            recalls => $patron->recalls->filter_by_current->search({},{ order_by => { -asc => 'created_date' } }),
            specific_patron => 1,
            waiting_recalls => $waiting_recalls,
        );
    }
}

if ( $patron ) {
    my $noissues;
    if ( $patron->gonenoaddress ) {
        $template->param( gonenoaddress => 1 );
        $noissues = 1;
    }
    if ( $patron->lost ) {
        $template->param( lost=> 1 );
        $noissues = 1;
    }
    if ( $patron->is_debarred ) {
        $template->param( is_debarred=> 1 );
        $noissues = 1;
    }
    my $account = $patron->account;
    if( ( my $owing = $account->non_issues_charges ) > 0 ) {
        my $noissuescharge = C4::Context->preference("noissuescharge") || 5; # FIXME If noissuescharge == 0 then 5, why??
        $noissues ||= ( not C4::Context->preference("AllowFineOverride") and ( $owing > $noissuescharge ) );
        $template->param(
            charges => 1,
            chargesamount => $owing,
        )
    } elsif ( $balance < 0 ) {
        $template->param(
            credits => 1,
            creditsamount => -$balance,
        );
    }

    # Check the debt of this patrons guarantors *and* the guarantees of those guarantors
    my $no_issues_charge_guarantors = C4::Context->preference("NoIssuesChargeGuarantorsWithGuarantees");
    if ( $no_issues_charge_guarantors ) {
        my $guarantors_non_issues_charges = $patron->relationships_debt({ include_guarantors => 1, only_this_guarantor => 0, include_this_patron => 1 });

        if ( $guarantors_non_issues_charges > $no_issues_charge_guarantors ) {
            $template->param(
                charges_guarantors_guarantees => $guarantors_non_issues_charges
            );
            $noissues = 1 unless C4::Context->preference("allowfineoverride");
        }
    }

    my $no_issues_charge_guarantees = C4::Context->preference("NoIssuesChargeGuarantees");
    $no_issues_charge_guarantees = undef unless looks_like_number( $no_issues_charge_guarantees );
    if ( defined $no_issues_charge_guarantees ) {
        my $guarantees_non_issues_charges = 0;
        my $guarantees = $patron->guarantee_relationships->guarantees;
        while ( my $g = $guarantees->next ) {
            $guarantees_non_issues_charges += $g->account->non_issues_charges;
        }
        if ( $guarantees_non_issues_charges > $no_issues_charge_guarantees ) {
            $template->param(
                charges_guarantees    => 1,
                chargesamount_guarantees => $guarantees_non_issues_charges,
            );
            $noissues = 1 unless C4::Context->preference("allowfineoverride");
        }
    }

    if ( $patron->has_overdues ) {
        $template->param( odues => 1 );
    }

    if ( $patron->borrowernotes ) {
        my $borrowernotes = $patron->borrowernotes;
        $borrowernotes =~ s#\n#<br />#g;
        $template->param(
            notes =>1,
            notesmsg => $borrowernotes,
        )
    }

    if ( $noissues ) {
        $template->param(
            noissues => ($force_allow_issue) ? 0 : 'true',
            forceallow => $force_allow_issue,
        );
    }

    my $patron_messages = $patron->messages->search(
        {},
        {
           join => 'manager',
           '+select' => ['manager.surname', 'manager.firstname' ],
           '+as' => ['manager_surname', 'manager_firstname'],
        }
    );
    $template->param( patron_messages => $patron_messages );

}

my $fast_cataloging = 0;
if ( Koha::BiblioFrameworks->find('FA') ) {
    $fast_cataloging = 1 
}

my $view = $batch
    ?'batch_checkout_view'
    : 'circview';

my @relatives;
if ( $patron ) {
    if ( my @guarantors = $patron->guarantor_relationships()->guarantors->as_list ) {
        push( @relatives, $_->id ) for @guarantors;
        push( @relatives, $_->id ) for $patron->siblings->as_list;
    } else {
        push( @relatives, $_->id ) for $patron->guarantee_relationships()->guarantees->as_list;
    }
}
my $relatives_issues_count =
  Koha::Database->new()->schema()->resultset('Issue')
  ->count( { borrowernumber => \@relatives } );

if ( $patron ) {
    my $av = Koha::AuthorisedValues->search({ category => 'ROADTYPE', authorised_value => $patron->streettype });
    my $roadtype = $av->count ? $av->next->lib : '';
    $template->param(
        roadtype          => $roadtype,
        patron            => $patron,
        categoryname      => $patron->category->description,
        expiry            => $patron->dateexpiry,
    );
}

# Restore date if changed by holds and/or save stickyduedate to session
if ($restoreduedatespec || $stickyduedate) {
    $duedatespec = $restoreduedatespec || $duedatespec;

    if ($stickyduedate) {
        $session->param( 'stickyduedate', $duedatespec );
    }
} elsif (defined($duedatespec) && !defined($restoreduedatespec)) {
    undef $duedatespec;
}

$template->param(
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    was_renewed       => scalar $query->param('was_renewed') ? 1 : 0,
    barcodes          => $barcodes,
    stickyduedate     => $stickyduedate,
    duedatespec       => $duedatespec,
    restoreduedatespec => $restoreduedatespec,
    message           => $message,
    totaldue          => sprintf('%.2f', $balance), # FIXME not used in template?
    inprocess         => $inprocess,
    $view             => 1,
    batch_allowed     => $batch_allowed,
    batch             => $batch,
    AudioAlerts           => C4::Context->preference("AudioAlerts"),
    fast_cataloging   => $fast_cataloging,
    CircAutoPrintQuickSlip   => C4::Context->preference("CircAutoPrintQuickSlip"),
    RoutingSerials => C4::Context->preference('RoutingSerials'),
    relatives_issues_count => $relatives_issues_count,
    relatives_borrowernumbers => \@relatives,
);


if ( C4::Context->preference("ExportCircHistory") ) {
    $template->param(csv_profiles => Koha::CsvProfiles->search({ type => 'marc' }));
}

my $has_modifications = Koha::Patron::Modifications->search( { borrowernumber => $borrowernumber } )->count;
$template->param(
    debt_confirmed            => $debt_confirmed,
    SpecifyDueDate            => $duedatespec_allow,
    PatronAutoComplete        => C4::Context->preference("PatronAutoComplete"),
    today_due_date_and_time   => dt_from_string()->set(hour => 23)->set(minute => 59),
    restriction_types         => scalar Koha::Patron::Restriction::Types->search(),
    has_modifications         => $has_modifications,
    override_high_holds       => $override_high_holds,
    nopermission              => scalar $query->param('nopermission'),
    autoswitched              => $autoswitched,
    logged_in_user            => $logged_in_user,
);

# Generate CSRF token for upload and delete image buttons
$template->param(
    csrf_token => Koha::Token->new->generate_csrf({ session_id => $query->cookie('CGISESSID'),}),
);

output_html_with_http_headers $query, $cookie, $template->output;
