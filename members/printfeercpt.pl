#!/usr/bin/perl


#writen 3rd May 2010 by kmkale@anantcorp.com adapted from boraccount.pl by chris@katipo.oc.nz
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

use strict;
use warnings;

use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date/;
use CGI;
use C4::Members;
use C4::Branch;
use C4::Accounts;

my $input=new CGI;


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/printfeercpt.tt",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {borrowers => 1, updatecharges => 'remaining_permissions'},
                            debug => 1,
                            });

my $borrowernumber=$input->param('borrowernumber');
my $action = $input->param('action') || '';
my $accountlines_id = $input->param('accountlines_id');

#get borrower details
my $data=GetMember('borrowernumber' => $borrowernumber);

if ( $action eq 'print' ) {
#  ReversePayment( $borrowernumber, $input->param('accountno') );
}

if ( $data->{'category_type'} eq 'C') {
   my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
   my $cnt = scalar(@$catcodes);
   $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
   $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
}

#get account details
my ($total,$accts,$numaccts)=GetMemberAccountRecords($borrowernumber);
my $totalcredit;
if($total <= 0){
        $totalcredit = 1;
}
my @accountrows; # this is for the tmpl-loop

my $toggle;
for (my $i=0;$i<$numaccts;$i++){
    next if ( $accts->[$i]{'accountlines_id'} ne $accountlines_id );
    if($i%2){
            $toggle = 0;
    } else {
            $toggle = 1;
    }
    $accts->[$i]{'toggle'} = $toggle;
    $accts->[$i]{'amount'}+=0.00;
    if($accts->[$i]{'amount'} <= 0){
        $accts->[$i]{'amountcredit'} = 1;
	$accts->[$i]{'amount'}*=-1.00;
    }
    $accts->[$i]{'amountoutstanding'}+=0.00;
    if($accts->[$i]{'amountoutstanding'} <= 0){
        $accts->[$i]{'amountoutstandingcredit'} = 1;
    }
    my %row = ( 'date'              => format_date($accts->[$i]{'date'}),
                'amountcredit' => $accts->[$i]{'amountcredit'},
                'amountoutstandingcredit' => $accts->[$i]{'amountoutstandingcredit'},
                'toggle' => $accts->[$i]{'toggle'},
                'description'       => $accts->[$i]{'description'},
				'itemnumber'       => $accts->[$i]{'itemnumber'},
				'biblionumber'       => $accts->[$i]{'biblionumber'},
                'amount'            => sprintf("%.2f",$accts->[$i]{'amount'}),
                'amountoutstanding' => sprintf("%.2f",$accts->[$i]{'amountoutstanding'}),
                'accountno' => $accts->[$i]{'accountno'},
                accounttype => $accts->[$i]{accounttype},
                );

    if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
        $row{'printtitle'}=1;
        $row{'title'} = $accts->[$i]{'title'};
    }

    push(@accountrows, \%row);
}

$template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' );

my ($picture, $dberror) = GetPatronImage($data->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

$template->param(
    finesview           => 1,
    firstname           => $data->{'firstname'},
    surname             => $data->{'surname'},
    borrowernumber      => $borrowernumber,
    cardnumber          => $data->{'cardnumber'},
    categorycode        => $data->{'categorycode'},
    category_type       => $data->{'category_type'},
 #   category_description => $data->{'description'},
    categoryname		 => $data->{'description'},
    address             => $data->{'address'},
    address2            => $data->{'address2'},
    city                => $data->{'city'},
    zipcode             => $data->{'zipcode'},
    country             => $data->{'country'},
    phone               => $data->{'phone'},
    email               => $data->{'email'},
    branchcode          => $data->{'branchcode'},
	branchname			=> GetBranchName($data->{'branchcode'}),
    total               => sprintf("%.2f",$total),
    totalcredit         => $totalcredit,
	is_child        => ($data->{'category_type'} eq 'C'),
    accounts            => \@accountrows );

output_html_with_http_headers $input, $cookie, $template->output;
