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
    my $sessionID=$query->cookie('sessionID');
    my $message='';
    warn "SID: ".$sessionID;

    my $dbh=C4Connect();
    my $sth=$dbh->prepare("select userid,ip,lasttime from sessions where sessionid=?");
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	if ($lasttime<time()-20) {
	    # timed logout
	    warn "$sessionID logged out due to inactivity.";
	    $message="You have been logged out due to inactivity.";
	    my $sti=$dbh->prepare("delete from sessions where sessionID=?");
	    $sti->execute($sessionID);
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
    
    ($sessionID) || ($sessionID=int(rand()*100000).'-'.time());
    my $userid=$query->param('userid');
    my $password=$query->param('password');
    if ($userid eq 'librarian' && $password eq 'koha') {
	my $sti=$dbh->prepare("insert into sessions (sessionID, userid, ip,lasttime) values (?, ?, ?, ?)");
	$sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
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
<table border=1>
<tr><th colspan=2><font size=+2>Koha Login</font></th></tr>
<tr><td>Name:</td><td><input name=userid></td></tr>
<tr><td>Password:</td><td><input type=password name=password></td></tr>
<tr><td colspan=2 align=center><input type=submit value=login></td></tr>
</table>
</form>
</body>
</html>
|;
	exit
    }
}


END { }       # module clean-up code here (global destructor)
