#!/usr/bin/perl

# wrriten 15/10/2002 by finlay@katipo.oc.nz
# script to display borrowers account details in the opac

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;

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
	$accts->[$i]{'date'} = format_date($accts->[$i]{'date'});
    $accts->[$i]{'amount'} = sprintf("%.2f", $accts->[$i]{'amount'});
	if($accts->[$i]{'amount'} >= 0){
		$accts->[$i]{'amountcredit'} = 1;
	}
    $accts->[$i]{'amountoutstanding'} =sprintf("%.2f", $accts->[$i]{'amountoutstanding'});
	if($accts->[$i]{'amountoutstanding'} >= 0){
		$accts->[$i]{'amountoutstandingcredit'} = 1;
	}
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


$template->param( ACCOUNT_LINES => $accts,
			     LibraryName => C4::Context->preference("LibraryName"),
				suggestion => C4::Context->preference("suggestion"),
				virtualshelves => C4::Context->preference("virtualshelves")
 );

$template->param( total => sprintf("%.2f",$total) );

#$template->param(loggeninuser => $loggedinuser);
output_html_with_http_headers $query, $cookie, $template->output;

