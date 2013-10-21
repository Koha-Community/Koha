#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;
use C4::Context;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Circulation;
use Koha::DateUtils;
use Koha::Database;

my $cgi = new CGI;

my ( $template, $librarian, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/renew.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

my $schema = Koha::Database->new()->schema();

my $barcode        = $cgi->param('barcode');
my $override_limit = $cgi->param('override_limit');
my $override_holds = $cgi->param('override_holds');

my ( $item, $issue, $borrower );
my $error = q{};

if ($barcode) {
    $item = $schema->resultset("Item")->single( { barcode => $barcode } );

    if ($item) {

        $issue = $item->issues()->single();

        if ($issue) {

            $borrower = $issue->borrower();
            
            if ( ( $borrower->debarred() || q{} ) lt dt_from_string()->ymd() ) {
                my $can_renew;
                ( $can_renew, $error ) =
                  CanBookBeRenewed( $borrower->borrowernumber(),
                    $item->itemnumber(), $override_limit );

                if ( $error eq 'on_reserve' ) {
                    if ($override_holds) {
                        $can_renew = 1;
                        $error     = undef;
                    }
                    else {
                        $can_renew = 0;
                    }
                }

                if ($can_renew) {
                    my $date_due = AddRenewal( undef, $item->itemnumber() );
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
        error    => $error
    );
}

output_html_with_http_headers( $cgi, $cookie, $template->output );
