#!/usr/bin/perl

use C4::Output;
use CGI;

my $query=new CGI;
my $language=$query->param('language');
my $url=$query->referer();

setlanguagecookie($query,$language,$url);
