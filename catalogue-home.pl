#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

print $query->header(-cookie => $cookie);

print startpage();
print startmenu('catalogue');

print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";

my $classlist='';
open C, "/usr/local/koha/intranet/htdocs/includes/cat-class-list.inc";
while (<C>) {
    $classlist.=$_;
}
open H, "/usr/local/koha/intranet/htdocs/catalogue/index.html";
while (<H>) {
    s/<!-- CLASSLIST -->/$classlist/;
    print $_;
}
close H;


print endpage();
print endmenu('catalogue');
