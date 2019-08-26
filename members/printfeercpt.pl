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
use CGI qw ( -utf8 );
use C4::Members;
use C4::Accounts;
use C4::Letters;
use Koha::Account::Lines;
use Koha::DateUtils;
use Koha::Patrons;
use Koha::Patron::Categories;

my $input=new CGI;


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/printfeercpt.tt",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {borrowers => 'edit_borrowers', updatecharges => 'remaining_permissions'},
                            debug => 1,
                            });

my $borrowernumber=$input->param('borrowernumber');
my $action = $input->param('action') || '';
my $accountlines_id = $input->param('accountlines_id');
my $change_given = $input->param('change_given');

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

#get account details
my $total = $patron->account->balance;

# FIXME This whole stuff is ugly and should be rewritten
# FIXME We should pass the $accts iterator to the template and do this formatting part there
my $accountline_object = Koha::Account::Lines->find($accountlines_id);
my $accountline = $accountline_object->unblessed;
my $totalcredit;
if($total <= 0){
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

my $letter = C4::Letters::getletter( 'circulation', 'ACCOUNT_CREDIT', C4::Context::mybranch, 'print', $patron->lang );

my @account_offsets = Koha::Account::Offsets->search( { credit_id => $accountline_object->id } );

$template->param(
    letter      => $letter,
    patron      => $patron,
    library     => C4::Context::mybranch,
    offsets     => \@account_offsets,
    credit      => $accountline_object,

    finesview   => 1,
    total       => $total,
    totalcredit => $totalcredit,
    accounts    => [$accountline],        # FIXME There is always only 1 row!

    change_given => $change_given,
);

output_html_with_http_headers $input, $cookie, $template->output;
