#!/usr/bin/perl

#simple script to provide basic redirection
#used by members section

use CGI;
use strict;

my $input=new CGI;

my $choice=$input->param('chooseform');

if ($choice eq 'adult'){
  print $input->redirect("/cgi-bin/koha/memberentry.pl?type=Add");
}

if ($choice eq 'organisation'){
  print $input->redirect("/cgi-bin/koha/imemberentry.pl?type=Add");
}
