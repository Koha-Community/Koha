#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Database;

my $configfile=configfile();
my $intranetdir=$configfile->{'intranetdir'};

my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);

print $query->header(-cookie => $cookie);

print startpage();
print startmenu('catalogue');

print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";

my $classlist='';
open C, "$intranetdir/htdocs/includes/cat-class-list.inc";
while (<C>) {
    $classlist.=$_;
}
open H, "$intranetdir/htdocs/catalogue/index.html";
while (<H>) {
    s/<!-- CLASSLIST -->/$classlist/;
    print $_;
}
close H;


print endpage();
print endmenu('catalogue');
