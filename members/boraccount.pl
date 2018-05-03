#!/usr/bin/perl


#written 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details


# Copyright 2000-2002 Katipo Communications
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
use C4::Members::Attributes qw(GetBorrowerAttributes);
use Koha::Patrons;
use Koha::Patron::Categories;

my $input=new CGI;


my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "members/boraccount.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers     => 'edit_borrowers',
                             updatecharges => 'remaining_permissions'},
        debug           => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $action = $input->param('action') || '';

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

if ( $action eq 'reverse' ) {
  ReversePayment( scalar $input->param('accountlines_id') );
}
elsif ( $action eq 'void' ) {
    my $payment_id = scalar $input->param('accountlines_id');
    my $payment    = Koha::Account::Lines->find( $payment_id );
    $payment->void();
}

if ( $patron->is_child ) {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

#get account details
my $total = $patron->account->balance;

my $accts = Koha::Account::Lines->search(
    { borrowernumber => $patron->borrowernumber },
    { order_by       => { -desc => 'accountlines_id' } }
);

my $totalcredit;
if($total <= 0){
        $totalcredit = 1;
}

my $reverse_col = 0; # Flag whether we need to show the reverse column
my @accountlines;
while ( my $line = $accts->next ) {
    # FIXME We should pass the $accts iterator to the template and do this formatting part there
    my $accountline = $line->unblessed;
    $accountline->{amount} += 0.00;
    if ($accountline->{amount} <= 0 ) {
        $accountline->{amountcredit} = 1;
    }
    $accountline->{amountoutstanding} += 0.00;
    if ( $accountline->{amountoutstanding} <= 0 ) {
        $accountline->{amountoutstandingcredit} = 1;
    }

    $accountline->{amount} = sprintf '%.2f', $accountline->{amount};
    $accountline->{amountoutstanding} = sprintf '%.2f', $accountline->{amountoutstanding};
    if ($accountline->{amount} < 0) {
        $accountline->{payment} = 1
          if ( $accountline->{accounttype} =~ /^Pay/ );

        $reverse_col = 1;
    }

    if ( $accountline->{itemnumber} ) {
        # Because we will not have access to the object from the template
        $accountline->{item} = $line->item;
    }
    push @accountlines, $accountline;
}

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(
    patron              => $patron,
    finesview           => 1,
    total               => sprintf("%.2f",$total),
    totalcredit         => $totalcredit,
    reverse_col         => $reverse_col,
    accounts            => \@accountlines,
);

output_html_with_http_headers $input, $cookie, $template->output;
