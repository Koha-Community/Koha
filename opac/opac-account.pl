#!/usr/bin/perl

# wrriten 15/10/2002 by finlay@katipo.oc.nz
# script to display borrowers account details in the opac

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Auth;
use HTML::Template;

my $query = new CGI;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-account.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);

my @bordat;
$bordat[0] = $borr;

$template->param( BORROWER_INFO => \@bordat );


#get account details
my ($numaccts,$accts,$total) = getboracctrecord(undef,$borr);

for (my $i=0;$i<$numaccts;$i++){
    $accts->[$i]{'amount'}+=0.00;
    $accts->[$i]{'amountoutstanding'}+=0.00;
    if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
	$accts->[$i]{'print_title'};
    }
}

# add the row parity
my $num = 0;
foreach my $row (@$accts) {
    $row->{'even'} = 1 if $num % 2 == 0;
    $row->{'odd'} = 1 if $num % 2 == 1;
    $num++;
}


$template->param( ACCOUNT_LINES => $accts );

$template->param( total => $total );

#$template->param(loggeninuser => $loggedinuser);
output_html_with_http_headers $query, $cookie, $template->output;

