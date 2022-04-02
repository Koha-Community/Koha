#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Circulation qw( barcodedecode CanBookBeRenewed GetLatestAutoRenewDate AddRenewal );
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Database;
use Koha::BiblioFrameworks;

my $cgi = CGI->new;

my ( $template, $librarian, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/renew.tt",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

my $schema = Koha::Database->new()->schema();

my $barcode        = $cgi->param('barcode') // '';
my $unseen         = $cgi->param('unseen') || 0;
$barcode = barcodedecode($barcode) if $barcode;
my $override_limit = $cgi->param('override_limit');
my $override_holds = $cgi->param('override_holds');
my $hard_due_date  = $cgi->param('hard_due_date');

my ( $item, $issue, $borrower );
my $error = q{};
my ( $soonest_renew_date, $latest_auto_renew_date );

if ($barcode) {
    $barcode = barcodedecode($barcode) if $barcode;
    $item = $schema->resultset("Item")->single( { barcode => $barcode } );

    if ($item) {

        $issue = $item->issue();

        if ($issue) {

            $borrower = $issue->patron();
            
            if ( ( $borrower->debarred() || q{} ) lt dt_from_string()->ymd() ) {
                my $can_renew;
                my $info;
                ( $can_renew, $error, $info ) =
                  CanBookBeRenewed( $borrower->borrowernumber(),
                    $item->itemnumber(), $override_limit );

                if ( $error && ($error eq 'on_reserve') ) {
                    if ($override_holds) {
                        $can_renew = 1;
                        $error     = undef;
                    }
                    else {
                        $can_renew = 0;
                    }
                }

                if ( $error && ($error eq 'too_soon' or $error eq 'auto_too_soon') ) {
                    $soonest_renew_date = $info->{soonest_renew_date};
                }
                if ( $error && ( $error eq 'auto_too_late' ) ) {
                    $latest_auto_renew_date = C4::Circulation::GetLatestAutoRenewDate(
                        $borrower->borrowernumber(),
                        $item->itemnumber(),
                    );
                }
                if ($can_renew) {
                    my $branchcode = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
                    my $date_due;
                    if ( $cgi->param('renewonholdduedate') ) {
                        $date_due = dt_from_string( scalar $cgi->param('renewonholdduedate'));
                    }
                    if ( C4::Context->preference('SpecifyDueDate') && $hard_due_date ) {
                        $date_due = dt_from_string( $hard_due_date );
                    }
                    $date_due = AddRenewal(
                        undef,
                        $item->itemnumber(),
                        $branchcode,
                        $date_due,
                        undef,
                        undef,
                        !$unseen
                    );
                    $template->param( date_due => $date_due );
                }
            }
            else {
                $error = "patron_restricted";
            }
        }
        else {
            $error = "no_checkout";
        }
    }
    else {
        $error = "no_item";
    }

    $template->param(
        item     => $item,
        issue    => $issue,
        borrower => $borrower,
        error    => $error,
        soonestrenewdate => $soonest_renew_date,
        latestautorenewdate => $latest_auto_renew_date,
    );
}

$template->param( hard_due_date => ($hard_due_date ? output_pref({ str => $hard_due_date, dateformat => 'iso' }) : undef) );
# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

output_html_with_http_headers( $cgi, $cookie, $template->output );
