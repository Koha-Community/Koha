#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

print $query->header(-cookie => $cookie);

print startpage();
print startmenu('report');

print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";

open H, "/usr/local/koha/intranet/htdocs/reports/index.html";
while (<H>) {
    print $_;
}
close H;


print endpage();
print endmenu('report');
