package C4::Auth;

use strict;
use Digest::MD5 qw(md5_base64);


require Exporter;
use C4::Database;
use C4::Koha;

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
    if (my $userid=$ENV{'REMOTE_USER'}) {
	# Using Basic Authentication, no cookies required
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return ($userid, $cookie, '');
    }
    my $sessionID=$query->cookie('sessionID');
    my $message='';

    my $dbh=C4Connect();
    my $sth=$dbh->prepare("select userid,ip,lasttime from sessions where sessionid=?");
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	if ($lasttime<time()-7200) {
	    # timed logout
	    $message="You have been logged out due to inactivity.";
	    my $sti=$dbh->prepare("delete from sessions where sessionID=?");
	    $sti->execute($sessionID);
	    my $scriptname=$ENV{'SCRIPT_NAME'};
	    my $selfurl=$query->self_url();
	    $sti=$dbh->prepare("insert into sessionqueries (sessionID, userid, value) values (?, ?, ?)");
	    $sti->execute($sessionID, $userid, $selfurl);
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
	    close L;
	} elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
	    # Different ip than originally logged in from
	    my $newip=$ENV{'REMOTE_ADDR'};

	    $message="ERROR ERROR ERROR ERROR<br>Attempt to re-use a cookie from a different ip address.<br>(authenticated from $ip, this request from $newip)";
	} else {
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    my $sti=$dbh->prepare("update sessions set lasttime=? where sessionID=?");
	    $sti->execute(time(), $sessionID);
	    return ($userid, $cookie, $sessionID);
	}
    }



    if ($authnotrequired) {
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return('', $cookie, '');
    } else {
	($sessionID) || ($sessionID=int(rand()*100000).'-'.time());
	my $userid=$query->param('userid');
	my $password=$query->param('password');
	if (checkpw($dbh, $userid, $password)) {
	    my $sti=$dbh->prepare("delete from sessions where sessionID=? and userid=?");
	    $sti->execute($sessionID, $userid);
	    $sti=$dbh->prepare("insert into sessions (sessionID, userid, ip,lasttime) values (?, ?, ?, ?)");
	    $sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
	    $sti=$dbh->prepare("select value from sessionqueries where sessionID=? and userid=?");
	    $sti->execute($sessionID, $userid);
	    if ($sti->rows) {
		my ($selfurl) = $sti->fetchrow;
		my $stj=$dbh->prepare("delete from sessionqueries where sessionID=?");
		$stj->execute($sessionID);
		($selfurl) || ($selfurl=$ENV{'SCRIPT_NAME'});
		print $query->redirect($selfurl);
		exit;
	    }
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged in  at %30s.\n", $userid, $ENV{'REMOTE_ADDR'}, $time;
	    close L;
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    return ($userid, $cookie, $sessionID);
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
<table border=0 cellpadding=10 cellspacing=0 width=60%>
    <tr><td align=center valign=top>

    <table border=0 bgcolor=#dddddd cellpadding=10 cellspacing=0>
    <tr><th colspan=2 background=/images/background-mem.gif><font size=+2>Koha Login</font></th></tr>
    <tr><td>Name:</td><td><input name=userid></td></tr>
    <tr><td>Password:</td><td><input type=password name=password></td></tr>
    <tr><td colspan=2 align=center><input type=submit value=login></td></tr>
    </table>
<!--
    
    </td><td align=center valign=top>

    <table border=0 bgcolor=#dddddd cellpadding=10 cellspacing=0>
    <tr><th background=/images/background-mem.gif><font size=+2>Demo Information</font></th></tr>
    <td>
    Log in as librarian/koha or patron/koha.  The timeout is set to 40 seconds of
    inactivity for the purposes of this demo.  You can navigate to the Circulation
    or Acquisitions modules and you should see an indicator in the upper left of
    the screen saying who you are logged in as.  If you want to try it out with
    a longer timout period, log in as tonnesen/koha and there will be no
    timeout period.
    <p>
    You can also log in using a patron cardnumber.   Try V10000008 and
    V1000002X with password koha.
    </td>
    </tr>
    </table>
-->

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


sub checkpw {

# This should be modified to allow a select of authentication schemes (ie LDAP)
# as well as local authentication through the borrowers tables passwd field
#

    my ($dbh, $userid, $password) = @_;
    my $sth=$dbh->prepare("select password from borrowers where userid=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1;
	}
    }
    my $sth=$dbh->prepare("select password from borrowers where cardnumber=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1;
	}
    }
    my $configfile=configfile();
    if ($userid eq $configfile->{'user'} && $password eq $configfile->{'pass'}) {
        # Koha superuser account
	return 1;
    }
    return 0;
}


END { }       # module clean-up code here (global destructor)
