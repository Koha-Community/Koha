#!/usr/bin/perl

#script to show list of budgets and bookfunds
#written 4/2/00 by chris@katipo.co.nz
#called as an include by the acquisitions index page

use C4::Acquisitions;
use C4::Biblio;
use C4::Search;
use CGI;
use C4::Auth;
my $input=new CGI;

my $flagsrequired;
#$flagsrequired->{borrower}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $module=$input->param('module');

SWITCH: {
    if ($module eq 'acquisitions') { acquisitions(); last SWITCH; }
    if ($module eq 'somethingelse') { somethingelse(); last SWITCH; }
}


sub acquisitions {
    # FIXME
    # instead of getting a hash, then reading/writing to it at least twice 
    # and up to four times, maybe this should be a different function -
    # areAquisitionsSimple() which returns a boolean
    my %systemprefs=systemprefs();
    ($systemprefs{'acquisitions'}) || ($systemprefs{'acquisitions'}='normal');
    if ($systemprefs{'acquisitions'} eq 'simple') {
	print $input->redirect("/cgi-bin/koha/acqui.simple/addbooks.pl");
    } elsif ($systemprefs{'acquisitions'} eq 'normal') {
	print $input ->redirect("/acquisitions");
    } else {
	print $input ->redirect("/acquisitions");
    }
}


sub somethingelse {
# just an example subroutine
}
