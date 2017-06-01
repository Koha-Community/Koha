#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details


# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

use C4::Auth;
use C4::Output;
use CGI qw ( -utf8 );

use C4::Members;
use C4::Accounts;
use C4::Items;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::Patrons;

use Koha::Patron::Categories;

my $input=new CGI;
my $flagsrequired = { borrowers => 'edit_borrowers', updatecharges => 1 };

my $borrowernumber=$input->param('borrowernumber');

my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}
my $add=$input->param('add');

if ($add){
    if ( checkauth( $input, 0, $flagsrequired, 'intranet' ) ) {
        # Note: If the logged in user is not allowed to see this patron an invoice can be forced
        # Here we are trusting librarians not to hack the system
        my $barcode = $input->param('barcode');
        my $itemnum;
        if ($barcode) {
            $itemnum = GetItemnumberFromBarcode($barcode);
        }
        my $desc    = $input->param('desc');
        my $note    = $input->param('note');
        my $amount  = $input->param('amount') || 0;
        $amount = -$amount;
        my $type = $input->param('type');
        manualinvoice( $borrowernumber, $itemnum, $desc, $type, $amount, $note );
        print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
    }
} else {
    my ($template, $loggedinuser, $cookie) = get_template_and_user(
        {
            template_name   => "members/mancredit.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { borrowers     => 'edit_borrowers',
                                 updatecharges => 'remaining_permissions' },
            debug           => 1,
        }
    );
    my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
    output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );
    if ( $patron->category->category_type eq 'C') {
        my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
        $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
        $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
    }

    $template->param( adultborrower => 1 ) if ( $patron->category->category_type =~ /^(A|I)$/ );

    if (C4::Context->preference('ExtendedPatronAttributes')) {
        my $attributes = GetBorrowerAttributes($borrowernumber);
        $template->param(
            ExtendedPatronAttributes => 1,
            extendedattributes => $attributes
        );
    }

    $template->param( patron => $patron );

    $template->param(
        finesview      => 1,
        is_child       => ($patron->category->category_type eq 'C'), # FIXME is_child should be a Koha::Patron method
        );
    output_html_with_http_headers $input, $cookie, $template->output;
}
