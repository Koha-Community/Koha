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

use Koha::Patrons;
use Koha::Patron::Categories;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "members/printinvoice.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired => { borrowers => 1, updatecharges => 'remaining_permissions' },
        debug           => 1,
    }
);

my $borrowernumber  = $input->param('borrowernumber');
my $action          = $input->param('action') || '';
my $accountlines_id = $input->param('accountlines_id');

my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}
my $category = $patron->category;
my $data = $patron->unblessed;
$data->{description} = $category->description;
$data->{category_type} = $category->category_type;

if ( $data->{'category_type'} eq 'C' ) {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

#get account details
my ( $total, $accts, $numaccts ) = GetMemberAccountRecords($borrowernumber);
my $totalcredit;
if ( $total <= 0 ) {
    $totalcredit = 1;
}

my @accountrows;    # this is for the tmpl-loop

my $toggle;
for ( my $i = 0 ; $i < $numaccts ; $i++ ) {
    next if ( $accts->[$i]{'accountlines_id'} ne $accountlines_id );

    if ( $i % 2 ) {
        $toggle = 0;
    } else {
        $toggle = 1;
    }

    $accts->[$i]{'toggle'} = $toggle;
    $accts->[$i]{'amount'} += 0.00;

    if ( $accts->[$i]{'amount'} <= 0 ) {
        $accts->[$i]{'amountcredit'} = 1;
    }

    $accts->[$i]{'amountoutstanding'} += 0.00;
    if ( $accts->[$i]{'amountoutstanding'} <= 0 ) {
        $accts->[$i]{'amountoutstandingcredit'} = 1;
    }

    my %row = (
        'date'                    => output_pref({ dt => dt_from_string( $accts->[$i]{'date'} ), dateonly => 1 }),
        'amountcredit'            => $accts->[$i]{'amountcredit'},
        'amountoutstandingcredit' => $accts->[$i]{'amountoutstandingcredit'},
        'toggle'                  => $accts->[$i]{'toggle'},
        'description'             => $accts->[$i]{'description'},
        'itemnumber'              => $accts->[$i]{'itemnumber'},
        'biblionumber'            => $accts->[$i]{'biblionumber'},
        'amount'                  => sprintf( "%.2f", $accts->[$i]{'amount'} ),
        'amountoutstanding'       => sprintf( "%.2f", $accts->[$i]{'amountoutstanding'} ),
        'accountno'               => $accts->[$i]{'accountno'},
        accounttype               => $accts->[$i]{accounttype},
        'note'                    => $accts->[$i]{'note'},
    );

    if ( $accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU' ) {
        $row{'printtitle'} = 1;
        $row{'title'}      = $accts->[$i]{'title'};
    }

    push( @accountrows, \%row );
}

$template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' || $data->{'category_type'} eq 'I' );

$template->param( picture => 1 ) if $patron->image;

$template->param(
    finesview      => 1,
    firstname      => $data->{'firstname'},
    surname        => $data->{'surname'},
    borrowernumber => $borrowernumber,
    cardnumber     => $data->{'cardnumber'},
    categorycode   => $data->{'categorycode'},
    category_type  => $data->{'category_type'},
    categoryname   => $data->{'description'},
    address        => $data->{'address'},
    address2       => $data->{'address2'},
    city           => $data->{'city'},
    zipcode        => $data->{'zipcode'},
    country        => $data->{'country'},
    phone          => $data->{'phone'},
    email          => $data->{'email'},
    branchcode     => $data->{'branchcode'},
    total          => sprintf( "%.2f", $total ),
    totalcredit    => $totalcredit,
    is_child       => ( $data->{'category_type'} eq 'C' ),
    accounts       => \@accountrows
);

output_html_with_http_headers $input, $cookie, $template->output;
