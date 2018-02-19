#!/usr/bin/perl

#written 3rd May 2010 by kmkale@anantcorp.com adapted from boraccount.pl by chris@katipo.oc.nz
#script to print fee receipts

# Copyright Koustubha Kale
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
use Koha::DateUtils;
use CGI qw ( -utf8 );
use C4::Members;
use C4::Accounts;

use Koha::Account::Lines;
use Koha::Patrons;
use Koha::Patron::Categories;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "members/printinvoice.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired => { borrowers => 'edit_borrowers', updatecharges => 'remaining_permissions' },
        debug           => 1,
    }
);

my $borrowernumber  = $input->param('borrowernumber');
my $action          = $input->param('action') || '';
my $accountlines_id = $input->param('accountlines_id');

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

if ( $patron->is_child ) {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

#get account details
my $total = $patron->account->balance;
my $accountline = Koha::Account::Lines->find($accountlines_id)->unblessed;

my $totalcredit;
if ( $total <= 0 ) {
    $totalcredit = 1;
}


$accountline->{'amount'} += 0.00;
if ( $accountline->{'amount'} <= 0 ) {
    $accountline->{'amountcredit'} = 1;
    $accountline->{'amount'} *= -1.00;
}
$accountline->{'amountoutstanding'} += 0.00;
if ( $accountline->{'amountoutstanding'} <= 0 ) {
    $accountline->{'amountoutstandingcredit'} = 1;
}

my %row = (
    'date'                    => dt_from_string( $accountline->{'date'} ),
    'amountcredit'            => $accountline->{'amountcredit'},
    'amountoutstandingcredit' => $accountline->{'amountoutstandingcredit'},
    'description'             => $accountline->{'description'},
    'amount'                  => sprintf( "%.2f", $accountline->{'amount'} ),
    'amountoutstanding' =>
      sprintf( "%.2f", $accountline->{'amountoutstanding'} ),
    'accountno' => $accountline->{'accountno'},
    accounttype => $accountline->{accounttype},
    'note'      => $accountline->{'note'},
);

$template->param(
    patron         => $patron,
    finesview      => 1,
    total          => sprintf( "%.2f", $total ),
    totalcredit    => $totalcredit,
    accounts       => [$accountline], # FIXME There is always only 1 row!
);

output_html_with_http_headers $input, $cookie, $template->output;
