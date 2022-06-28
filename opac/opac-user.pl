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


use Modern::Perl;

use CGI qw ( -utf8 );
use URI;

use C4::Auth qw( get_template_and_user );
use C4::Koha qw(
    getitemtypeimagelocation
    GetNormalizedISBN
    GetNormalizedUPC
);
use C4::Circulation qw( CanBookBeRenewed GetRenewCount GetIssuingCharges );
use C4::External::BakerTaylor qw( image_url link_url );
use C4::Reserves qw( GetReserveStatus );
use C4::Members;
use C4::Output qw( output_html_with_http_headers );
use Koha::Account::Lines;
use Koha::Biblios;
use Koha::Libraries;
use Koha::DateUtils qw( output_pref );
use Koha::Holds;
use Koha::Database;
use Koha::ItemTypes;
use Koha::Patron::Attribute::Types;
use Koha::Patrons;
use Koha::Patron::Messages;
use Koha::Patron::Discharge;
use Koha::Patrons;
use Koha::Ratings;
use Koha::Recalls;
use Koha::Token;

use constant ATTRIBUTE_SHOW_BARCODE => 'SHOW_BCODE';

use Scalar::Util qw( looks_like_number );
use Date::Calc qw( Date_to_Days Today );

my $query = CGI->new;

# CAS single logout handling
# Will print header and exit
if ( C4::Context->preference('casAuthentication') ) {
    require C4::Auth_with_cas;
    C4::Auth_with_cas::logout_if_required($query);
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
    }
);

my %renewed = map { $_ => 1 } split( ':', $query->param('renewed') || '' );

my $show_priority;
for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
    m/priority/ and $show_priority = 1;
}

my $patronupdate = $query->param('patronupdate');
my $canrenew = 1;

$template->param( shibbolethAuthentication => C4::Context->config('useshibboleth') );

# get borrower information ....
my $patron = Koha::Patrons->find( $borrowernumber );

if( $query->param('update_arc') && C4::Context->preference("AllowPatronToControlAutorenewal") ){
    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf({
            session_id => scalar $query->cookie('CGISESSID'),
            token  => scalar $query->param('csrf_token'),
        });

    my $autorenew_checkouts = $query->param('borrower_autorenew_checkouts');
    $patron->autorenew_checkouts( $autorenew_checkouts )->store() if defined $autorenew_checkouts;
}

my $borr = $patron->unblessed;

my (  $today_year,   $today_month,   $today_day) = Today();
my ($warning_year, $warning_month, $warning_day) = split /-/, $borr->{'dateexpiry'};

my $debar = Koha::Patrons->find( $borrowernumber )->is_debarred;
my $userdebarred;

if ($debar) {
    $userdebarred = 1;
    $template->param( 'userdebarred' => $userdebarred );
    if ( $debar ne "9999-12-31" ) {
        $borr->{'userdebarreddate'} = $debar;
    }
    # FIXME looks like $available is not needed
    # If a user is discharged they have a validated discharge available
    my $available = Koha::Patron::Discharge::count({
        borrowernumber => $borrowernumber,
        validated      => 1,
    });
    $template->param( 'discharge_available' => $available && Koha::Patron::Discharge::is_discharged({borrowernumber => $borrowernumber}) );
}

if ( $userdebarred || $borr->{'gonenoaddress'} || $borr->{'lost'} ) {
    $borr->{'flagged'} = 1;
    $canrenew = 0;
}

my $amountoutstanding = $patron->account->balance;
my $no_renewal_amt = C4::Context->preference( 'OPACFineNoRenewals' );
$no_renewal_amt = undef unless looks_like_number( $no_renewal_amt );
my $amountoutstandingfornewal =
  C4::Context->preference("OPACFineNoRenewalsIncludeCredit")
  ? $amountoutstanding
  : $patron->account->outstanding_debits->total_outstanding;

if (   C4::Context->preference('OpacRenewalAllowed')
    && defined($no_renewal_amt)
    && $amountoutstandingfornewal > $no_renewal_amt )
{
    $borr->{'flagged'} = 1;
    $canrenew = 0;
    $template->param(
        renewal_blocked_fines => $no_renewal_amt,
        renewal_blocked_fines_amountoutstanding => $amountoutstandingfornewal,
    );
}

my $maxoutstanding = C4::Context->preference('maxoutstanding');
if ( $amountoutstanding && ( $amountoutstanding > $maxoutstanding ) ){
    $borr->{blockedonfines} = 1;
}

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

my $saving_display = C4::Context->preference('OPACShowSavings');
if ( $saving_display =~ /user/ ) {
    $template->param( savings => $patron->get_savings );
}

# pass on any renew errors to the template for displaying
my $renew_error = $query->param('renew_error');

$template->param(
                    amountoutstanding => $amountoutstanding,
                    borrowernumber    => $borrowernumber,
                    patron_flagged    => $borr->{flagged},
                    OPACMySummaryHTML => (C4::Context->preference("OPACMySummaryHTML")) ? 1 : 0,
                    surname           => $borr->{surname},
                    RENEW_ERROR       => $renew_error,
                    borrower          => $borr,
                    csrf_token             => Koha::Token->new->generate_csrf({
                        session_id => scalar $query->cookie('CGISESSID'),
                    }),
                );

#get issued items ....

my $count          = 0;
my $overdues_count = 0;
my @overdues;
my @issuedat;
my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
my $pending_checkouts = $patron->pending_checkouts->search({}, { order_by => [ { -desc => 'date_due' }, { -asc => 'issue_id' } ] });
my $are_renewable_items = 0;
if ( $pending_checkouts->count ) { # Useless test
    while ( my $c = $pending_checkouts->next ) {
        my $issue = $c->unblessed_all_relateds;
        # check for reserves
        my $restype = GetReserveStatus( $issue->{'itemnumber'} );
        if ( $restype ) {
            $issue->{'reserved'} = 1;
        }

        # Must be moved in a module if reused
        my $charges = Koha::Account::Lines->search(
            {
                borrowernumber    => $patron->borrowernumber,
                amountoutstanding => { '>' => 0 },
                debit_type_code   => [ 'OVERDUE', 'LOST' ],
                itemnumber        => $issue->{itemnumber}
            },
        );
        $issue->{charges} = $charges->total_outstanding;

        my $rental_fines = Koha::Account::Lines->search(
            {
                borrowernumber    => $patron->borrowernumber,
                amountoutstanding => { '>' => 0 },
                debit_type_code   => { 'LIKE' => 'RENT_%' },
                itemnumber        => $issue->{itemnumber}
            }
        );
        $issue->{rentalfines} = $rental_fines->total_outstanding;

        # check if item is renewable
        my ($status,$renewerror,$info) = CanBookBeRenewed( $borrowernumber, $issue->{'itemnumber'} );
        (
            $issue->{'renewcount'},
            $issue->{'renewsallowed'},
            $issue->{'renewsleft'},
            $issue->{'unseencount'},
            $issue->{'unseenallowed'},
            $issue->{'unseenleft'}
        ) = GetRenewCount($borrowernumber, $issue->{'itemnumber'});
        ( $issue->{'renewalfee'}, $issue->{'renewalitemtype'} ) = GetIssuingCharges( $issue->{'itemnumber'}, $borrowernumber );
        $issue->{itemtype_object} = Koha::ItemTypes->find( Koha::Items->find( $issue->{itemnumber} )->effective_itemtype );
        if($status && C4::Context->preference("OpacRenewalAllowed")){
            $are_renewable_items = 1;
            $issue->{'status'} = $status;
        }

        $issue->{'renewed'} = $renewed{ $issue->{'itemnumber'} };

        if ($renewerror) {
            $issue->{'too_many'}       = 1 if $renewerror eq 'too_many';
            $issue->{'too_unseen'}     = 1 if $renewerror eq 'too_unseen';
            $issue->{'on_reserve'}     = 1 if $renewerror eq 'on_reserve';
            $issue->{'norenew_overdue'} = 1 if $renewerror eq 'overdue';
            $issue->{'auto_renew'}     = 1 if $renewerror eq 'auto_renew';
            $issue->{'auto_too_soon'}  = 1 if $renewerror eq 'auto_too_soon';
            $issue->{'auto_too_late'}  = 1 if $renewerror eq 'auto_too_late';
            $issue->{'auto_too_much_oweing'}  = 1 if $renewerror eq 'auto_too_much_oweing';
            $issue->{'item_denied_renewal'}  = 1 if $renewerror eq 'item_denied_renewal';

            if ( $renewerror eq 'too_soon' ) {
                $issue->{'too_soon'}         = 1;
                $issue->{'soonestrenewdate'} = $info->{soonest_renew_date};
            }
        }

        if ( $c->is_overdue ) {
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

        if ( C4::Context->preference('OpacStarRatings') eq 'all' ) {
            my $ratings = Koha::Ratings->search({ biblionumber => $issue->{biblionumber} });
            $issue->{ratings} = $ratings;
            $issue->{my_rating} = $borrowernumber ? $ratings->search({ borrowernumber => $borrowernumber })->next : undef;
        }

        my $biblio_object = Koha::Biblios->find($issue->{biblionumber});
        $issue->{biblio_object} = $biblio_object;
        push @issuedat, $issue;
        $count++;

        my $isbn = GetNormalizedISBN($issue->{'isbn'});
        $issue->{normalized_isbn} = $isbn;
        my $marcrecord = $biblio_object->metadata->record({ embed_items => 1, opac => 1, patron => $patron,});
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

        if ( C4::Context->preference('UseRecalls') ) {
            my $maybe_recalls = Koha::Recalls->search({ biblio_id => $issue->{biblionumber}, item_id => [ undef, $issue->{itemnumber} ], completed => 0 });
            while( my $recall = $maybe_recalls->next ) {
                if ( $recall->checkout and $recall->checkout->issue_id == $issue->{issue_id} ) {
                    $issue->{recall} = 1;
                    last;
                }
            }
        }
    }
}
my $overduesblockrenewing = C4::Context->preference('OverduesBlockRenewing');
$canrenew = 0 if ($overduesblockrenewing ne 'allow' and $overdues_count == $count) || !$are_renewable_items;

$template->param( ISSUES       => \@issuedat );
$template->param( issues_count => $count );
$template->param( canrenew     => $canrenew );
$template->param( OVERDUES       => \@overdues );
$template->param( overdues_count => $overdues_count );

my $show_barcode = Koha::Patron::Attribute::Types->search( # FIXME we should not need this search
    { code => ATTRIBUTE_SHOW_BARCODE } )->count;
if ($show_barcode) {
    my $patron_show_barcode = $patron->get_extended_attribute(ATTRIBUTE_SHOW_BARCODE);
    undef $show_barcode if $patron_show_barcode and not $patron_show_barcode->attribute;
}
$template->param( show_barcode => 1 ) if $show_barcode;

# now the reserved items....
my $reserves = $patron->holds->filter_out_has_cancellation_requests;

$template->param(
    RESERVES       => $reserves,
    showpriority   => $show_priority,
);

if ( C4::Context->preference('UseRecalls') ) {
    my $recalls = Koha::Recalls->search( { patron_id => $borrowernumber, completed => 0 } );
    $template->param( RECALLS => $recalls );
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
    C4::Context->preference("SyndeticsCoverImages") or
    ( C4::Context->preference('OPACCustomCoverImages') and C4::Context->preference('CustomCoverImagesURL') )
) {
        $template->param(JacketImages=>1);
}

$template->param(
    OverDriveCirculation => C4::Context->preference('OverDriveCirculation') || 0,
    overdrive_error      => scalar $query->param('overdrive_error') || undef,
    overdrive_tab        => scalar $query->param('overdrive_tab') || 0,
    RecordedBooksCirculation => C4::Context->preference('RecordedBooksClientSecret') && C4::Context->preference('RecordedBooksLibraryID'),
);

my $patron_messages = Koha::Patron::Messages->search(
    {
        borrowernumber => $borrowernumber,
        message_type => 'B',
    }
);

if (   C4::Context->preference('AllowPatronToSetCheckoutsVisibilityForGuarantor')
    || C4::Context->preference('AllowStaffToSetCheckoutsVisibilityForGuarantor') )
{
    my @relatives;
    # Filter out guarantees that don't want guarantor to see checkouts
    foreach my $gr ( $patron->guarantee_relationships->as_list ) {
        my $g = $gr->guarantee;
        push( @relatives, $g ) if $g->privacy_guarantor_checkouts;
    }
    $template->param( relatives => \@relatives );
}

if (   C4::Context->preference('AllowPatronToSetFinesVisibilityForGuarantor')
    || C4::Context->preference('AllowStaffToSetFinesVisibilityForGuarantor') )
{
    my @relatives_with_fines;
    # Filter out guarantees that don't want guarantor to see checkouts
    foreach my $gr ( $patron->guarantee_relationships->as_list ) {
        my $g = $gr->guarantee;
        push( @relatives_with_fines, $g ) if $g->privacy_guarantor_fines;
    }
    $template->param( relatives_with_fines => \@relatives_with_fines );
}

if ( C4::Context->preference("ArticleRequests") ) {
    $template->param(
        current_article_requests => [$patron->article_requests->filter_by_current->as_list],
    );
}

$template->param(
    patron_messages          => $patron_messages,
    opacnote                 => $borr->{opacnote},
    patronupdate             => $patronupdate,
    OpacRenewalAllowed       => C4::Context->preference("OpacRenewalAllowed"),
    userview                 => 1,
    SuspendHoldsOpac         => C4::Context->preference('SuspendHoldsOpac'),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
    OpacHoldNotes            => C4::Context->preference('OpacHoldNotes'),
    failed_holds             => scalar $query->param('failed_holds'),
);

# if not an empty string this indicates to return
# back to the opac-results page
my $search_query = $query->param('has-search-query');

if ($search_query) {

    print $query->redirect(
        -uri    => "/cgi-bin/koha/opac-search.pl?$search_query",
        -cookie => $cookie,
    );
}

# if not an empty string this indicates to return
# back to the page we triggered the login from
my $return = $query->param('return');
if ( $return ) {
    my $uri_syspref = C4::Context->preference('OPACBaseURL');
    if ( $uri_syspref ){
        my $uri = URI->new($uri_syspref);
        if ( $uri->isa('URI::http') && $uri->host() ){
            my $return_uri = URI->new($return);
            $return_uri->scheme( $uri->scheme() );
            $return_uri->authority( $uri->authority() );
            print $query->redirect(
                -uri    => "$return_uri",
                -cookie => $cookie,
            );
        }
    }
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
