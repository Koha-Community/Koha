#!/usr/bin/perl

# wrriten 15/10/2002 by finlay@katipo.oc.nz
# script to display borrowers account details in the opac

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Auth;

my $query = new CGI;

my $flagsrequired;
$flagsrequired->{borrow}=1;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired);

my $template = gettemplate("opac-account.tmpl", "opac");

# get borrower information ....
my $borrowernumber = getborrowernumber($loggedinuser);
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

$template->param( ACCOUNT_LINES => $accts );

$template->param( total => $total );

$template->param( loggedinuser => $loggedinuser );
print "Content-Type: text/html\n\n", $template->output; 
