#!/usr/bin/perl

use CGI;
use C4::Database;

my $query=new CGI;

my $sessionID=$query->cookie('sessionID');

my $sessions;
open (S, "/tmp/sessions");
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

exit;
if ($sessionID) {
    print "Logged out of $sessionID<br>\n";
    print "<a href=shelves.pl>Login</a>";
} else {
    print "Not logged in.<br>\n";
    print "<a href=shelves.pl>Login</a>";
}



