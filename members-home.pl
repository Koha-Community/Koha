#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;

my $query = new CGI;
my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query, 0, $flagsrequired);

print $query->header(-cookie => $cookie);

print startpage();
print startmenu('member');

print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";

open H, "/usr/local/koha/intranet/htdocs/members/index.html";
while (<H>) {
    print $_;
}
close H;


print endpage();
print endmenu('member');
