#!/usr/bin/perl

use CGI;
use C4::Database;
use C4::Output;

my $query=new CGI;

my $sessionID=$query->cookie('sessionID');


if ($ENV{'REMOTE_USER'}) {
    print $query->header();
    print startpage();
    print startmenu('catalogue');
    print qq|
<h1>Logout Feature Not Available</h1>
Your Koha server is configured to use a type of authentication called "Basic
Authentication" instead of using a cookies-based authentication system.  With
Basic Authentication, the only way to logout of Koha is by exiting your
browser.
|;
    print endmenu('catalogue');
    print endpage();
    exit;
}

my $dbh=C4Connect;

# Check that this is the ip that created the session before deleting it

my $sth=$dbh->prepare("select userid,ip from sessions where sessionID=?");
$sth->execute($sessionID);
my ($userid, $ip);
if ($sth->rows) {
    ($userid,$ip) = $sth->fetchrow;
    if ($ip ne $ENV{'REMOTE_ADDR'}) {
       # attempt to logout from a different ip than cookie was created at
       exit;
    }
}

$sth=$dbh->prepare("delete from sessions where sessionID=?");
$sth->execute($sessionID);
open L, ">>/tmp/sessionlog";
my $time=localtime(time());
printf L "%20s from %16s logged out at %30s (manual log out).\n", $userid, $ip, $time;
close L;

my $cookie=$query->cookie(-name => 'sessionID',
			  -value => '',
			  -expires => '+1y');

# Should redirect to intranet home page after logging out

print $query->redirect("mainpage.pl");

