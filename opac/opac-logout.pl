#!/usr/bin/perl

use CGI;
use C4::Context;
use C4::Output;
use HTML::Template;

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

my $sessions;
open (S, "/tmp/sessions");
	# FIXME - Come up with a better logging mechanism
while (my ($sid, $u, $lasttime) = split(/:/, <S>)) {
    chomp $lasttime;
    (next) unless ($sid);
    (next) if ($sid eq $sessionID);
    $sessions->{$sid}->{'userid'}=$u;
    $sessions->{$sid}->{'lasttime'}=$lasttime;
}
open (S, ">/tmp/sessions");
foreach (keys %$sessions) {
    my $userid=$sessions->{$_}->{'userid'};
    my $lasttime=$sessions->{$_}->{'lasttime'};
    print S "$_:$userid:$lasttime\n";
}

my $dbh = C4::Context->dbh;

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

my $sth=$dbh->prepare("delete from sessions where sessionID=?");
$sth->execute($sessionID);
open L, ">>/tmp/sessionlog";
my $time=localtime(time());
printf L "%20s from %16s logged out at %30s (manual log out).\n", $userid, $ip, $time;
close L;

my $cookie=$query->cookie(-name => 'sessionID',
			  -value => '',
			  -expires => '+1y');

# Should redirect to opac home page after logging out

print $query->redirect("/cgi-bin/koha/opac-main.pl");

exit;
if ($sessionID) {
    print "Logged out of $sessionID<br>\n";
    print "<a href=shelves.pl>Login</a>";
} else {
    print "Not logged in.<br>\n";
    print "<a href=shelves.pl>Login</a>";
}



