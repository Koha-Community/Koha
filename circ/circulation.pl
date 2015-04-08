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

use strict;
use warnings;
use CGI;
use DateTime;
use DateTime::Duration;
use C4::Output;
use C4::Print;
use C4::Auth qw/:DEFAULT get_session haspermission/;
use C4::Dates qw/format_date/;
use C4::Branch; # GetBranches
use C4::Koha;   # GetPrinter
use C4::Circulation;
use C4::Members;
use C4::Biblio;
use C4::Search;
use MARC::Record;
use C4::Reserves;
use C4::Context;
use CGI::Session;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::Borrower::Debarments qw(GetDebarments IsDebarred);
use Koha::DateUtils;
use Koha::Database;

use Date::Calc qw(
  Today
  Add_Delta_YM
  Add_Delta_Days
  Date_to_Days
);
use List::MoreUtils qw/uniq/;


#
# PARAMETERS READING
#
my $query = new CGI;

my $sessionID = $query->cookie("CGISESSID") ;
my $session = get_session($sessionID);

# branch and printer are now defined by the userenv
# but first we have to check if someone has tried to change them

my $branch = $query->param('branch');
if ($branch){
    # update our session so the userenv is updated
    $session->param('branch', $branch);
    $session->param('branchname', GetBranchName($branch));
}

my $printer = $query->param('printer');
if ($printer){
    # update our session so the userenv is updated
    $session->param('branchprinter', $printer);
}

if (!C4::Context->userenv && !$branch){
    if ($session->param('branch') eq 'NO_LIBRARY_SET'){
        # no branch set we can't issue
        print $query->redirect("/cgi-bin/koha/circ/selectbranchprinter.pl");
        exit;
    }
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user (
    {
        template_name   => 'circ/circulation.tt',
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
    }
);

my $branches = GetBranches();

my $force_allow_issue = $query->param('forceallow') || 0;
if (!C4::Auth::haspermission( C4::Context->userenv->{id} , { circulate => 'force_checkout' } )) {
    $force_allow_issue = 0;
}

my $onsite_checkout = $query->param('onsite_checkout');

my @failedrenews = $query->param('failedrenew');    # expected to be itemnumbers
our %renew_failed = ();
for (@failedrenews) { $renew_failed{$_} = 1; }

my @failedreturns = $query->param('failedreturn');
our %return_failed = ();
for (@failedreturns) { $return_failed{$_} = 1; }

my $findborrower = $query->param('findborrower') || q{};
$findborrower =~ s|,| |g;
my $borrowernumber = $query->param('borrowernumber');

$branch  = C4::Context->userenv->{'branch'};  
$printer = C4::Context->userenv->{'branchprinter'};


# If AutoLocation is not activated, we show the Circulation Parameters to chage settings of librarian
if (C4::Context->preference("AutoLocation") != 1) {
    $template->param(ManualLocation => 1);
}

if (C4::Context->preference("DisplayClearScreenButton")) {
    $template->param(DisplayClearScreenButton => 1);
}

my $barcode        = $query->param('barcode') || q{};
$barcode =~  s/^\s*|\s*$//g; # remove leading/trailing whitespace

$barcode = barcodedecode($barcode) if( $barcode && C4::Context->preference('itemBarcodeInputFilter'));
my $stickyduedate  = $query->param('stickyduedate') || $session->param('stickyduedate');
my $duedatespec    = $query->param('duedatespec')   || $session->param('stickyduedate');
my $issueconfirmed = $query->param('issueconfirmed');
my $cancelreserve  = $query->param('cancelreserve');
my $print          = $query->param('print') || q{};
my $debt_confirmed = $query->param('debt_confirmed') || 0; # Don't show the debt error dialog twice
my $charges        = $query->param('charges') || q{};

# Check if stickyduedate is turned off
if ( $barcode ) {
    # was stickyduedate loaded from session?
    if ( $stickyduedate && ! $query->param("stickyduedate") ) {
        $session->clear( 'stickyduedate' );
        $stickyduedate  = $query->param('stickyduedate');
        $duedatespec    = $query->param('duedatespec');
    }
    $session->param('auto_renew', $query->param('auto_renew'));
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
    if ($duedatespec) {
        if ($duedatespec =~ C4::Dates->regexp('syspref')) {
                $datedue = dt_from_string($duedatespec);
        } else {
            $invalidduedate = 1;
            $template->param(IMPOSSIBLE=>1, INVALID_DATE=>$duedatespec);
        }
    }
}

our $todaysdate = C4::Dates->new->output('iso');

# check and see if we should print
if ( $barcode eq '' && $print eq 'maybe' ) {
    $print = 'yes';
}

my $inprocess = ($barcode eq '') ? '' : $query->param('inprocess');
if ( $barcode eq '' && $charges eq 'yes' ) {
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
my $borrowerslist;
my $message;
if ($findborrower) {
    my $borrowers = Search($findborrower, 'cardnumber') || [];
    if (C4::Context->preference("AddPatronLists")) {
        if (C4::Context->preference("AddPatronLists")=~/code/){
            my $categories = GetBorrowercategoryList;
            $categories->[0]->{'first'} = 1;
            $template->param(categories=>$categories);
        }
    }
    if ( @$borrowers == 0 ) {
        $query->param( 'findborrower', '' );
        $message = "'$findborrower'";
    }
    elsif ( @$borrowers == 1 ) {
        $borrowernumber = $borrowers->[0]->{'borrowernumber'};
        $query->param( 'borrowernumber', $borrowernumber );
        $query->param( 'barcode',           '' );
    }
    else {
        $borrowerslist = $borrowers;
    }
}

# get the borrower information.....
my $borrower;
if ($borrowernumber) {
    $borrower = GetMemberDetails( $borrowernumber, 0 );
    my ( $od, $issue, $fines ) = GetMemberIssuesAndFines( $borrowernumber );

    # Warningdate is the date that the warning starts appearing
    my (  $today_year,   $today_month,   $today_day) = Today();
    my ($warning_year, $warning_month, $warning_day) = split /-/, $borrower->{'dateexpiry'};
    my (  $enrol_year,   $enrol_month,   $enrol_day) = split /-/, $borrower->{'dateenrolled'};
    # Renew day is calculated by adding the enrolment period to today
    my (  $renew_year,   $renew_month,   $renew_day);
    if ($enrol_year*$enrol_month*$enrol_day>0) {
        (  $renew_year,   $renew_month,   $renew_day) =
        Add_Delta_YM( $enrol_year, $enrol_month, $enrol_day,
            0 , $borrower->{'enrolmentperiod'});
    }
    # if the expiry date is before today ie they have expired
    if ( !$borrower->{'dateexpiry'} || $warning_year*$warning_month*$warning_day==0
        || Date_to_Days($today_year,     $today_month, $today_day  ) 
         > Date_to_Days($warning_year, $warning_month, $warning_day) )
    {
        #borrowercard expired, no issues
        $template->param(
            flagged  => "1",
            noissues => ($force_allow_issue) ? 0 : "1",
            forceallow => $force_allow_issue,
            expired => "1",
            renewaldate => format_date("$renew_year-$renew_month-$renew_day")
        );
    }
    # check for NotifyBorrowerDeparture
    elsif ( C4::Context->preference('NotifyBorrowerDeparture') &&
            Date_to_Days(Add_Delta_Days($warning_year,$warning_month,$warning_day,- C4::Context->preference('NotifyBorrowerDeparture'))) <
            Date_to_Days( $today_year, $today_month, $today_day ) ) 
    {
        # borrower card soon to expire warn librarian
        $template->param("warndeparture" => format_date($borrower->{dateexpiry}),
        flagged       => "1",);
        if (C4::Context->preference('ReturnBeforeExpiry')){
            $template->param("returnbeforeexpiry" => 1);
        }
    }
    $template->param(
        overduecount => $od,
        issuecount   => $issue,
        finetotal    => $fines
    );

    if ( IsDebarred($borrowernumber) ) {
        $template->param(
            'userdebarred'    => $borrower->{debarred},
            'debarredcomment' => $borrower->{debarredcomment},
        );

        if ( $borrower->{debarred} ne "9999-12-31" ) {
            $template->param( 'userdebarreddate' =>
                  C4::Dates::format_date( $borrower->{debarred} ) );
        }
    }

}

#
# STEP 3 : ISSUING
#
#
if ($barcode) {
    # always check for blockers on issuing
    my ( $error, $question, $alerts ) =
    CanBookBeIssued( $borrower, $barcode, $datedue , $inprocess );
    my $blocker = $invalidduedate ? 1 : 0;

    $template->param( alert => $alerts );

    #  Get the item title for more information
    my $getmessageiteminfo = GetBiblioFromItemNumber(undef,$barcode);
    $template->param(
        authvalcode_notforloan => C4::Koha::GetAuthValCode('items.notforloan', $getmessageiteminfo->{'frameworkcode'}),
    );
    # Fix for bug 7494: optional checkout-time fallback search for a book

    if ( $error->{'UNKNOWN_BARCODE'}
        && C4::Context->preference("itemBarcodeFallbackSearch") )
    {
     $template->param( FALLBACK => 1 );

        my $query = "kw=" . $barcode;
        my ( $searcherror, $results, $total_hits ) = SimpleSearch($query);

        # if multiple hits, offer options to librarian
        if ( $total_hits > 0 ) {
            my @options = ();
            foreach my $hit ( @{$results} ) {
                my $chosen =
                  TransformMarcToKoha( C4::Context->dbh,
                    C4::Search::new_record_from_zebra('biblioserver',$hit) );

                # offer all barcodes individually
                if ( $chosen->{barcode} ) {
                    foreach my $barcode ( sort split(/\s*\|\s*/, $chosen->{barcode}) ) {
                        my %chosen_single = %{$chosen};
                        $chosen_single{barcode} = $barcode;
                        push( @options, \%chosen_single );
                    }
                }
            }
            $template->param( options => \@options );
        }
    }

    unless( $onsite_checkout and C4::Context->preference("OnSiteCheckoutsForce") ) {
        delete $question->{'DEBT'} if ($debt_confirmed);
        foreach my $impossible ( keys %$error ) {
            $template->param(
                $impossible => $$error{$impossible},
                IMPOSSIBLE  => 1
            );
            $blocker = 1;
        }
    }
    if( !$blocker || $force_allow_issue ){
        my $confirm_required = 0;
        unless($issueconfirmed){
            #  Get the item title for more information
            my $getmessageiteminfo  = GetBiblioFromItemNumber(undef,$barcode);
	    $template->{VARS}->{'additional_materials'} = $getmessageiteminfo->{'materials'};
            $template->param( itemhomebranch => $getmessageiteminfo->{'homebranch'} );

            # pass needsconfirmation to template if issuing is possible and user hasn't yet confirmed.
            foreach my $needsconfirmation ( keys %$question ) {
                $template->param(
                    $needsconfirmation => $$question{$needsconfirmation},
                    getTitleMessageIteminfo => $getmessageiteminfo->{'title'},
                    getBarcodeMessageIteminfo => $getmessageiteminfo->{'barcode'},
                    NEEDSCONFIRMATION  => 1,
                    onsite_checkout => $onsite_checkout,
                );
                $confirm_required = 1;
            }
        }
        unless($confirm_required) {
            AddIssue( $borrower, $barcode, $datedue, $cancelreserve, undef, undef, { onsite_checkout => $onsite_checkout, auto_renew => $session->param('auto_renew') } );
            $session->clear('auto_renew');
            $inprocess = 1;
        }
    }
    
    my ( $od, $issue, $fines ) = GetMemberIssuesAndFines($borrowernumber);
    $template->param( issuecount => $issue );
}

# reload the borrower info for the sake of reseting the flags.....
if ($borrowernumber) {
    $borrower = GetMemberDetails( $borrowernumber, 0 );
}

##################################################################################
# BUILD HTML
# show all reserves of this borrower, and the position of the reservation ....
if ($borrowernumber) {
    $template->param(
        holds_count => Koha::Database->new()->schema()->resultset('Reserve')
          ->count( { borrowernumber => $borrowernumber } ) );
    my @borrowerreserv = GetReservesFromBorrowernumber($borrowernumber);

    my @WaitingReserveLoop;
    foreach my $num_res (@borrowerreserv) {
        if ( $num_res->{'found'} && $num_res->{'found'} eq 'W' ) {
            my $getiteminfo  = GetBiblioFromItemNumber( $num_res->{'itemnumber'} );
            my $itemtypeinfo = getitemtypeinfo( (C4::Context->preference('item-level_itypes')) ? $getiteminfo->{'itype'} : $getiteminfo->{'itemtype'} );
            my %getWaitingReserveInfo;
            $getWaitingReserveInfo{title} = $getiteminfo->{'title'};
            $getWaitingReserveInfo{biblionumber} =
              $getiteminfo->{'biblionumber'};
            $getWaitingReserveInfo{itemtype} = $itemtypeinfo->{'description'};
            $getWaitingReserveInfo{author}   = $getiteminfo->{'author'};
            $getWaitingReserveInfo{itemcallnumber} =
              $getiteminfo->{'itemcallnumber'};
            $getWaitingReserveInfo{reservedate} =
              format_date( $num_res->{'reservedate'} );
            $getWaitingReserveInfo{waitingat} =
              GetBranchName( $num_res->{'branchcode'} );
            $getWaitingReserveInfo{waitinghere} = 1
              if $num_res->{'branchcode'} eq $branch;
            push( @WaitingReserveLoop, \%getWaitingReserveInfo );
        }
    }
    $template->param( WaitingReserveLoop => \@WaitingReserveLoop );
    $template->param( adultborrower => 1 )
      if ( $borrower->{'category_type'} eq 'A' );
}

my @values;
my %labels;
my $selectborrower;
if ($borrowerslist) {
    foreach (
        sort {(lc $a->{'surname'} cmp lc $b->{'surname'} || lc $a->{'firstname'} cmp lc $b->{'firstname'})
        } @$borrowerslist
      )
    {
        push @values, $_->{'borrowernumber'};
        $labels{ $_->{'borrowernumber'} } =
"$_->{'surname'}, $_->{'firstname'} ... ($_->{'cardnumber'} - $_->{'categorycode'} - $_->{'branchcode'}) ...  $_->{'address'} ";
    }
    $selectborrower = {
        values => \@values,
        labels => \%labels,
    };
}

#title
my $flags = $borrower->{'flags'};
foreach my $flag ( sort keys %$flags ) {
    $template->param( flagged=> 1);
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

my $amountold = $borrower->{flags}->{'CHARGES'}->{'message'} || 0;
$amountold =~ s/^.*\$//;    # remove upto the $, if any

my ( $total, $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );

if ( $borrowernumber && $borrower->{'category_type'} eq 'C') {
    my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
    my $cnt = scalar(@$catcodes);
    $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
    $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
}

my $lib_messages_loop = GetMessages( $borrowernumber, 'L', $branch );
if($lib_messages_loop){ $template->param(flagged => 1 ); }

my $bor_messages_loop = GetMessages( $borrowernumber, 'B', $branch );
if($bor_messages_loop){ $template->param(flagged => 1 ); }

# Computes full borrower address
my @fulladdress;
push @fulladdress, $borrower->{'streetnumber'} if ( $borrower->{'streetnumber'} );
push @fulladdress, C4::Koha::GetAuthorisedValueByCode( 'ROADTYPE', $borrower->{'streettype'} ) if ( $borrower->{'streettype'} );
push @fulladdress, $borrower->{'address'} if ( $borrower->{'address'} );

my $fast_cataloging = 0;
if (defined getframeworkinfo('FA')) {
    $fast_cataloging = 1 
}

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

my @relatives = GetMemberRelatives( $borrower->{'borrowernumber'} );
my $relatives_issues_count =
  Koha::Database->new()->schema()->resultset('Issue')
  ->count( { borrowernumber => \@relatives } );

$template->param(
    lib_messages_loop => $lib_messages_loop,
    bor_messages_loop => $bor_messages_loop,
    all_messages_del  => C4::Context->preference('AllowAllMessageDeletion'),
    findborrower      => $findborrower,
    borrower          => $borrower,
    borrowernumber    => $borrowernumber,
    branch            => $branch,
    branchname        => GetBranchName($borrower->{'branchcode'}),
    printer           => $printer,
    printername       => $printer,
    firstname         => $borrower->{'firstname'},
    surname           => $borrower->{'surname'},
    showname          => $borrower->{'showname'},
    category_type     => $borrower->{'category_type'},
    was_renewed       => $query->param('was_renewed') ? 1 : 0,
    expiry            => format_date($borrower->{'dateexpiry'}),
    categorycode      => $borrower->{'categorycode'},
    categoryname      => $borrower->{description},
    address           => join(' ', @fulladdress),
    address2          => $borrower->{'address2'},
    email             => $borrower->{'email'},
    emailpro          => $borrower->{'emailpro'},
    borrowernotes     => $borrower->{'borrowernotes'},
    city              => $borrower->{'city'},
    state              => $borrower->{'state'},
    zipcode           => $borrower->{'zipcode'},
    country           => $borrower->{'country'},
    phone             => $borrower->{'phone'},
    mobile            => $borrower->{'mobile'},
    phonepro          => $borrower->{'phonepro'},
    cardnumber        => $borrower->{'cardnumber'},
    othernames        => $borrower->{'othernames'},
    amountold         => $amountold,
    barcode           => $barcode,
    stickyduedate     => $stickyduedate,
    duedatespec       => $duedatespec,
    message           => $message,
    selectborrower    => $selectborrower,
    totaldue          => sprintf('%.2f', $total),
    inprocess         => $inprocess,
    is_child          => ($borrowernumber && $borrower->{'category_type'} eq 'C'),
    circview => 1,
    soundon           => C4::Context->preference("SoundOn"),
    fast_cataloging   => $fast_cataloging,
    CircAutoPrintQuickSlip   => C4::Context->preference("CircAutoPrintQuickSlip"),
    activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
    SuspendHoldsIntranet => C4::Context->preference('SuspendHoldsIntranet'),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
    RoutingSerials => C4::Context->preference('RoutingSerials'),
    relatives_issues_count => $relatives_issues_count,
    relatives_borrowernumbers => \@relatives,
);

# save stickyduedate to session
if ($stickyduedate) {
    $session->param( 'stickyduedate', $duedatespec );
}

my ($picture, $dberror) = GetPatronImage($borrower->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

# get authorised values with type of BOR_NOTES

my $canned_notes = GetAuthorisedValues("BOR_NOTES");

$template->param(
    debt_confirmed            => $debt_confirmed,
    SpecifyDueDate            => $duedatespec_allow,
    CircAutocompl             => C4::Context->preference("CircAutocompl"),
    AllowRenewalLimitOverride => C4::Context->preference("AllowRenewalLimitOverride"),
    canned_bor_notes_loop     => $canned_notes,
    debarments                => GetDebarments({ borrowernumber => $borrowernumber }),
    todaysdate                => dt_from_string()->set(hour => 23)->set(minute => 59),
);

output_html_with_http_headers $query, $cookie, $template->output;
