#!/usr/bin/perl

#simple script to provide basic redirection
#used by members section

use CGI;
use C4::Auth;
use strict;

my $input=new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $choice=$input->param('chooseform');

if ($choice eq 'adult'){
  print $input->redirect("/cgi-bin/koha/memberentry.pl?type=Add");
}

if ($choice eq 'organisation'){
  print $input->redirect("/cgi-bin/koha/imemberentry.pl?type=Add");
}
