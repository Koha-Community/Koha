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
use DateTime;
use DateTime::Duration;
use C4::Output;
use C4::Print;
use C4::Auth qw/:DEFAULT get_session haspermission/;
use C4::Koha;   # GetPrinter
use C4::Circulation;
use C4::Utils::DataTables::Members;
use C4::Members;
use C4::Biblio;
use C4::Search;
use MARC::Record;
use C4::Reserves;
use Koha::Holds;
use C4::Context;
use CGI::Session;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::AuthorisedValues;
use Koha::CsvProfiles;
use Koha::Patrons;
use Koha::Patron::Debarments qw(GetDebarments);
use Koha::DateUtils;
use Koha::Database;
use Koha::BiblioFrameworks;
use Koha::Items;
use Koha::Patron::Messages;
use Koha::SearchEngine;
use Koha::SearchEngine::Search;
use Koha::Patron::Modifications;

use Date::Calc qw(
  Today
  Add_Delta_Days
  Date_to_Days
);
use List::MoreUtils qw/uniq/;

#
# PARAMETERS READING
#
my $query = new CGI;

my $override_high_holds     = $query->param('override_high_holds');
my $override_high_holds_tmp = $query->param('override_high_holds_tmp');

my $sessionID = $query->cookie("CGISESSID") ;
my $session = get_session($sessionID);
if (!C4::Context->userenv){
    if ($session->param('branch') eq 'NO_LIBRARY_SET'){
        # no branch set we can't issue
        print $query->redirect("/cgi-bin/koha/circ/selectbranchprinter.pl");
        exit;
    }
}

my $barcodes = [];
my $barcode =  $query->param('barcode');
my $findborrower;
my $autoswitched;
my $borrowernumber = $query->param('borrowernumber');

if (C4::Context->preference("AutoSwitchPatron") && $barcode) {
    if (Koha::Patrons->search( { cardnumber => $barcode} )->count() > 0) {
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
    my @batch_category_codes = split '\|', C4::Context->preference('BatchCheckoutsValidCategories');
    my $categorycode = $patron->categorycode;
    if ( $categorycode && grep {/^$categorycode$/} @batch_category_codes ) {
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
        authnotrequired => 0,
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
    }
);
my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";

my $force_allow_issue = $query->param('forceallow') || 0;
if (!C4::Auth::haspermission( C4::Context->userenv->{id} , { circulate => 'force_checkout' } )) {
    $force_allow_issue = 0;
}

my $onsite_checkout = $query->param('onsite_checkout');

my @failedrenews = $query->multi_param('failedrenew');    # expected to be itemnumbers
our %renew_failed = ();
for (@failedrenews) { $renew_failed{$_} = 1; }

my @failedreturns = $query->multi_param('failedreturn');
our %return_failed = ();
for (@failedreturns) { $return_failed{$_} = 1; }

my $searchtype = $query->param('searchtype') || q{contain};

my $branch = C4::Context->userenv->{'branch'};

if (C4::Context->preference("DisplayClearScreenButton")) {
    $template->param(DisplayClearScreenButton => 1);
}

for my $barcode ( @$barcodes ) {
    $barcode =~ s/^\s*|\s*$//g; # remove leading/trailing whitespace
    $barcode = barcodedecode($barcode)
        if( $barcode && C4::Context->preference('itemBarcodeInputFilter'));
}

my $stickyduedate  = $query->param('stickyduedate') || $session->param('stickyduedate');
my $duedatespec    = $query->param('duedatespec')   || $session->param('stickyduedate');
$duedatespec = eval { output_pref( { dt => dt_from_string( $duedatespec ), dateformat => 'iso', timeformat => '24hr' }); }
    if ( $duedatespec );
my $restoreduedatespec  = $query->param('restoreduedatespec') || $duedatespec || $session->param('stickyduedate');
if ( $restoreduedatespec && $restoreduedatespec eq "highholds_empty" ) {
    undef $restoreduedatespec;
}
my $issueconfirmed = $query->param('issueconfirmed');
my $cancelreserve  = $query->param('cancelreserve');
my $print          = $query->param('print') || q{};
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

my ($datedue,$invalidduedate);

my $duedatespec_allow = C4::Context->preference('SpecifyDueDate');
if( $onsite_checkout && !$duedatespec_allow ) {
    $datedue = output_pref({ dt => dt_from_string, dateonly => 1, dateformat => 'iso' });
    $datedue .= ' 23:59:00';
} elsif( $duedatespec_allow ) {
    if ( $duedatespec ) {
        $datedue = eval { dt_from_string( $duedatespec ) };
        if (! $datedue ) {
            $invalidduedate = 1;
            $template->param( IMPOSSIBLE=>1, INVALID_DATE=>$duedatespec );
        }
    }
}

# check and see if we should print
if ( @$barcodes == 0 && $print eq 'maybe' ) {
    $print = 'yes';
}

my $inprocess = (@$barcodes == 0) ? '' : $query->param('inprocess');
if ( @$barcodes == 0 && $charges eq 'yes' ) {
    $template->param(
        PAYCHARGES     => 'yes',
        borrowernumber => $borrowernumber
    );
}

if ( $print eq 'yes' && $borrowernumber ne '' ) {
    if ( C4::Context->boolean_preference('printcirculationslips') ) {
        my $letter = IssueSlip($branch, $borrowernumber, "QUICK");
        NetworkPrint($letter->{content});
    }
    $query->param( 'borrowernumber', '' );
    $borrowernumber = '';
}

#
# STEP 2 : FIND BORROWER
# if there is a list of find borrowers....
#
my $message;
if ($findborrower) {
    my $patron = Koha::Patrons->find( { cardnumber => $findborrower } );
    if ( $patron ) {
        $borrowernumber = $patron->borrowernumber;
    } else {
        my $dt_params = { iDisplayLength => -1 };
        my $results = C4::Utils::DataTables::Members::search(
            {
                searchmember => $findborrower,
                searchtype   => $searchtype,
                dt_params    => $dt_params,
            }
        );
        my $borrowers = $results->{patrons};
        if ( scalar @$borrowers == 1 ) {
            $borrowernumber = $borrowers->[0]->{borrowernumber};
            $query->param( 'borrowernumber', $borrowernumber );
            $query->param( 'barcode',           '' );
        } elsif ( @$borrowers ) {
            $template->param( borrowers => $borrowers );
        } else {
            $query->param( 'findborrower', '' );
            $message = "'$findborrower'";
        }
    }
}

# get the borrower information.....
$patron ||= Koha::Patrons->find( $borrowernumber ) if $borrowernumber;
if ($patron) {

    $template->param( borrowernumber => $patron->borrowernumber );
    output_and_exit_if_error( $query, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

    my $overdues = $patron->get_overdues;
    my $issues = $patron->checkouts;
    my $balance = $patron->account->balance;


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
        );

        if ( $patron->debarred ne "9999-12-31" ) {
            $template->param( 'userdebarreddate' => $patron->debarred );
        }
    }

}

#
# STEP 3 : ISSUING
#
#
if (@$barcodes) {
  my $checkout_infos;
  for my $barcode ( @$barcodes ) {
    my $template_params = { barcode => $barcode };
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
    my ( $biblio, $mss );

    if ( $item ) {
        $biblio = $item->biblio;
        my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $biblio->frameworkcode, kohafield => 'items.notforloan', authorised_value => { not => undef } });
        $template_params->{authvalcode_notforloan} = $mss->count ? $mss->next->authorised_value : undef;
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
            my @options = ();
            foreach my $hit ( @{$results} ) {
                my $chosen =
                  TransformMarcToKoha( C4::Search::new_record_from_zebra('biblioserver',$hit) );

                # offer all barcodes individually
                if ( $chosen->{barcode} ) {
                    foreach my $barcode ( sort split(/\s*\|\s*/, $chosen->{barcode}) ) {
                        my %chosen_single = %{$chosen};
                        $chosen_single{barcode} = $barcode;
                        push( @options, \%chosen_single );
                    }
                }
            }
            $template_params->{options} = \@options;
        }
    }

    if ( $error->{UNKNOWN_BARCODE} or not $onsite_checkout or not C4::Context->preference("OnSiteCheckoutsForce") ) {
        delete $question->{'DEBT'} if ($debt_confirmed);
        foreach my $impossible ( keys %$error ) {
            $template_params->{$impossible} = $$error{$impossible};
            $template_params->{IMPOSSIBLE} = 1;
            $blocker = 1;
        }
    }

    if( $item and ( !$blocker or $force_allow_issue ) ){
        my $confirm_required = 0;
        unless($issueconfirmed){
            #  Get the item title for more information
            my $materials = $item->materials;
            my $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({ frameworkcode => $biblio->frameworkcode, kohafield => 'items.materials', authorised_value => $materials });
            $materials = $descriptions->{lib} // $materials;
            $template_params->{additional_materials} = $materials;
            $template_params->{itemhomebranch} = $item->homebranch;

            # pass needsconfirmation to template if issuing is possible and user hasn't yet confirmed.
            foreach my $needsconfirmation ( keys %$question ) {
                $template_params->{$needsconfirmation} = $$question{$needsconfirmation};
                $template_params->{getTitleMessageIteminfo} = $biblio->title;
                $template_params->{getBarcodeMessageIteminfo} = $item->barcode;
                $template_params->{NEEDSCONFIRMATION} = 1;
                $template_params->{onsite_checkout} = $onsite_checkout;
                $template_params->{auto_renew} = $session->param('auto_renew');
                $confirm_required = 1;
            }
        }
        unless($confirm_required) {
            my $switch_onsite_checkout = exists $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED};
            my $issue = AddIssue( $patron->unblessed, $barcode, $datedue, $cancelreserve, undef, undef, { onsite_checkout => $onsite_checkout, auto_renew => $session->param('auto_renew'), switch_onsite_checkout => $switch_onsite_checkout, } );
            $template_params->{issue} = $issue;
            $session->clear('auto_renew');
            $inprocess = 1;
        }
    }

    if ($question->{RESERVE_WAITING} or $question->{RESERVED}){
        $template->param(
            reserveborrowernumber => $question->{'resborrowernumber'}
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
}

#title
my $flags = $patron ? C4::Members::patronflags( $patron->unblessed ) : {};
foreach my $flag ( sort keys %$flags ) {
    $flags->{$flag}->{'message'} =~ s#\n#<br />#g;
    if ( $flags->{$flag}->{'noissues'} ) {
        $template->param(
            noissues => ($force_allow_issue) ? 0 : 'true',
            forceallow => $force_allow_issue,
        );
        if ( $flag eq 'GNA' ) {
            $template->param( gna => 'true' );
        }
        elsif ( $flag eq 'LOST' ) {
            $template->param( lost => 'true' );
        }
        elsif ( $flag eq 'DBARRED' ) {
            $template->param( dbarred => 'true' );
        }
        elsif ( $flag eq 'CHARGES' ) {
            $template->param(
                charges    => 'true',
                chargesmsg => $flags->{'CHARGES'}->{'message'},
                chargesamount => $flags->{'CHARGES'}->{'amount'},
                charges_is_blocker => 1
            );
        }
        elsif ( $flag eq 'CHARGES_GUARANTEES' ) {
            $template->param(
                charges_guarantees    => 'true',
                chargesmsg_guarantees => $flags->{'CHARGES_GUARANTEES'}->{'message'},
                chargesamount_guarantees => $flags->{'CHARGES_GUARANTEES'}->{'amount'},
                charges_guarantees_is_blocker => 1
            );
        }
        elsif ( $flag eq 'CREDITS' ) {
            $template->param(
                credits    => 'true',
                creditsmsg => $flags->{'CREDITS'}->{'message'},
                creditsamount => sprintf("%.02f", -($flags->{'CREDITS'}->{'amount'})), # from patron's pov
            );
        }
    }
    else {
        if ( $flag eq 'CHARGES' ) {
            $template->param(
                charges    => 'true',
                chargesmsg => $flags->{'CHARGES'}->{'message'},
                chargesamount => $flags->{'CHARGES'}->{'amount'},
            );
        }
        elsif ( $flag eq 'CHARGES_GUARANTEES' ) {
            $template->param(
                charges_guarantees    => 'true',
                chargesmsg_guarantees => $flags->{'CHARGES_GUARANTEES'}->{'message'},
                chargesamount_guarantees => $flags->{'CHARGES_GUARANTEES'}->{'amount'},
            );
        }
        elsif ( $flag eq 'CREDITS' ) {
            $template->param(
                credits    => 'true',
                creditsmsg => $flags->{'CREDITS'}->{'message'},
                creditsamount => sprintf("%.02f", -($flags->{'CREDITS'}->{'amount'})), # from patron's pov
            );
        }
        elsif ( $flag eq 'ODUES' ) {
            $template->param(
                odues    => 'true',
                oduesmsg => $flags->{'ODUES'}->{'message'}
            );

            my $items = $flags->{$flag}->{'itemlist'};
            if ( ! $query->param('module') || $query->param('module') ne 'returns' ) {
                $template->param( nonreturns => 'true' );
            }
        }
        elsif ( $flag eq 'NOTES' ) {
            $template->param(
                notes    => 'true',
                notesmsg => $flags->{'NOTES'}->{'message'}
            );
        }
    }
}

my $total = $patron ? $patron->account->balance : 0;

if ( $patron && $patron->is_child) {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

my $messages = Koha::Patron::Messages->search(
    {
        'me.borrowernumber' => $borrowernumber,
    },
    {
       join => 'manager',
       '+select' => ['manager.surname', 'manager.firstname' ],
       '+as' => ['manager_surname', 'manager_firstname'],
    }
);

my $fast_cataloging = 0;
if ( Koha::BiblioFrameworks->find('FA') ) {
    $fast_cataloging = 1 
}

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}
my $view = $batch
    ?'batch_checkout_view'
    : 'circview';

my @relatives;
if ( $borrowernumber ) {
    if ( $patron ) {
        if ( my $guarantor = $patron->guarantor ) {
            push @relatives, $guarantor->borrowernumber;
            push @relatives, $_->borrowernumber for $patron->siblings;
        } else {
            push @relatives, $_->borrowernumber for $patron->guarantees;
        }
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
    messages           => $messages,
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    was_renewed       => scalar $query->param('was_renewed') ? 1 : 0,
    barcodes          => $barcodes,
    stickyduedate     => $stickyduedate,
    duedatespec       => $duedatespec,
    restoreduedatespec => $restoreduedatespec,
    message           => $message,
    totaldue          => sprintf('%.2f', $total),
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
    $template->param(csv_profiles => [ Koha::CsvProfiles->search({ type => 'marc' }) ]);
}

my $has_modifications = Koha::Patron::Modifications->search( { borrowernumber => $borrowernumber } )->count;
$template->param(
    debt_confirmed            => $debt_confirmed,
    SpecifyDueDate            => $duedatespec_allow,
    CircAutocompl             => C4::Context->preference("CircAutocompl"),
    debarments                => scalar GetDebarments({ borrowernumber => $borrowernumber }),
    todaysdate                => output_pref( { dt => dt_from_string()->set(hour => 23)->set(minute => 59), dateformat => 'sql' } ),
    has_modifications         => $has_modifications,
    override_high_holds       => $override_high_holds,
    nopermission              => scalar $query->param('nopermission'),
    autoswitched              => $autoswitched,
);

output_html_with_http_headers $query, $cookie, $template->output;
