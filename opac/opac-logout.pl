#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use CGI;
use C4::Context;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use HTML::Template::Pro;
use CGI::Session;

my $query=new CGI;

my $sessionID=$query->cookie('CGISESSID');

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
close S;
open (S, ">/tmp/sessions");
foreach (keys %$sessions) {
    my   $userid=$sessions->{$_}->{'userid'};
    my $lasttime=$sessions->{$_}->{'lasttime'};
    print S "$_:$userid:$lasttime\n";
}
close S;

my $dbh = C4::Context->dbh;
# Check that this is the ip that created the session before deleting it
# This script and function are apparently unfinished.  --atz (Dec 4 2007)
my $session = get_session($sessionID);
$session->flush;
$session->delete;
my $sth=$dbh->prepare("delete from sessions where sessionID=?");
$sth->execute($sessionID);
open L, ">>/tmp/sessionlog";
printf L "%20s from %16s logged out at %30s (manual log out).\n", $userid, $ip, localtime;	
							# where is $ip is coming from??
close L;

my $cookie=$query->cookie(-name => 'CGISESSID',
        -value => '',
        -expires => '+1y');

# Should redirect to opac home page after logging out
print $query->redirect("/cgi-bin/koha/opac-main.pl");
exit;

