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

use strict;
use warnings;

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
        flagsrequired   => { borrowers     => 1,
                             updatecharges => 'remaining_permissions'},
        debug           => 1,
    }
);

my $borrowernumber=$input->param('borrowernumber');
my $action = $input->param('action') || '';

#get patron details
my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

if ( $action eq 'reverse' ) {
  ReversePayment( scalar $input->param('accountlines_id') );
}

if ( $patron->category->category_type eq 'C') {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next )  if $patron_categories->count == 1;
}

#get account details
my ($total,$accts,undef)=GetMemberAccountRecords($borrowernumber);
my $totalcredit;
if($total <= 0){
        $totalcredit = 1;
}

my $reverse_col = 0; # Flag whether we need to show the reverse column
foreach my $accountline ( @{$accts}) {
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
    if ($accountline->{accounttype} =~ /^Pay/) {
        $accountline->{payment} = 1;
        $reverse_col = 1;
    }
}

$template->param( adultborrower => 1 ) if ( $patron->category->category_type =~ /^(A|I)$/ );

$template->param( picture => 1 ) if $patron->image;

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(%{ $patron->unblessed });

$template->param(
    finesview           => 1,
    borrowernumber      => $borrowernumber,
    total               => sprintf("%.2f",$total),
    totalcredit         => $totalcredit,
    is_child            => ($patron->category->category_type eq 'C'),
    reverse_col         => $reverse_col,
    accounts            => $accts,
);

output_html_with_http_headers $input, $cookie, $template->output;
