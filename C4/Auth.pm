package C4::Auth;

use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	     &checkauth
);



sub checkauth {
    my $query=shift;
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired=shift;
    if (my $userid=$ENV{'REMOTE_USERNAME'}) {
	# Using Basic Authentication, no cookies required
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return ($userid, $cookie, '');
    }
    my $sessionID=$query->cookie('sessionID');
    my $message='';
    warn "SID: ".$sessionID;

    my $dbh=C4Connect();
    my $sth=$dbh->prepare("select userid,ip,lasttime from sessions where sessionid=?");
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	if ($lasttime<time()-20 && $userid ne 'tonnesen') {
	    # timed logout
	    warn "$sessionID logged out due to inactivity.";
	    $message="You have been logged out due to inactivity.";
	    my $sti=$dbh->prepare("delete from sessions where sessionID=?");
	    $sti->execute($sessionID);
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
	    close L;
	} elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
	    # Different ip than originally logged in from
	    warn "$sessionID came from a new ip address.";
	    $message="ERROR ERROR ERROR ERROR<br>Attempt to re-use a cookie from a different ip address.";
	} else {
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    warn "$sessionID had a valid cookie.";
	    my $sti=$dbh->prepare("update sessions set lasttime=? where sessionID=?");
	    $sti->execute(time(), $sessionID);
	    return ($userid, $cookie, $sessionID);
	}
    }



    warn "$sessionID wasn't in sessions table.";
    if ($authnotrequired) {
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return('', $cookie, '');
    } else {
	($sessionID) || ($sessionID=int(rand()*100000).'-'.time());
	my $userid=$query->param('userid');
	my $password=$query->param('password');
	if (($userid eq 'librarian' || $userid eq 'tonnesen' || $userid eq 'patron') && $password eq 'koha') {
	    my $sti=$dbh->prepare("insert into sessions (sessionID, userid, ip,lasttime) values (?, ?, ?, ?)");
	    $sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged in  at %30s.\n", $userid, $ENV{'REMOTE_ADDR'}, $time;
	    close L;
	    return ($userid, $sessionID, $sessionID);
	} else {
	    if ($userid) {
		$message="Invalid userid or password entered.";
	    }
	    my $parameters;
	    foreach (param $query) {
		$parameters->{$_}=$query->{$_};
	    }
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    print $query->header(-cookie=>$cookie);
	    print qq|
<html>
<body background=/images/kohaback.jpg>
<center>
<h2>$message</h2>

<form method=post>
<table border=0 cellpadding=10 width=60%>
    <tr><td align=center valign=top>
    <table border=0 bgcolor=#dddddd cellpadding=10>
    <tr><th colspan=2 background=/images/background-mem.gif><font size=+2>Koha Login</font></th></tr>
    <tr><td>Name:</td><td><input name=userid></td></tr>
    <tr><td>Password:</td><td><input type=password name=password></td></tr>
    <tr><td colspan=2 align=center><input type=submit value=login></td></tr>
    </table>
    
    </td><td align=center valign=top>

    <table border=0 bgcolor=#dddddd cellpadding=10>
    <tr><th background=/images/background-mem.gif><font size=+2>Demo Information</font></th></tr>
    <td>
    Log in as librarian/koha or patron/koha.  The timeout is set to 20 seconds of
    inactivity for the purposes of this demo.  You can navigate to the Circulation
    or Acquisitions modules and you should see an indicator in the upper left of
    the screen saying who you are logged in as.  If you want to try it out with
    a longer timout period, log in as tonnesen/koha and the timeout period will
    be 10 minutes.
    </td>
    </tr>
    </table>
    </td></tr>
</table>
</form>
</body>
</html>
|;
	    exit;
	}
    }
}


END { }       # module clean-up code here (global destructor)
