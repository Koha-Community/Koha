package C4::Auth;


# Copyright 2000-2002 Katipo Communications
#
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
	     &getborrowernumber
);


sub getuserflags {
    my $cardnumber=shift;
    my $dbh=shift;
    my $userflags;
    my $sth=$dbh->prepare("SELECT flags FROM borrowers WHERE cardnumber=?");
    $sth->execute($cardnumber);
    my ($flags) = $sth->fetchrow;
    $sth=$dbh->prepare("SELECT bit, flag FROM userflags");
    $sth->execute;
    while (my ($bit, $flag) = $sth->fetchrow) {
	if ($flags & (2**$bit)) {
	    $userflags->{$flag}=1;
	}
    }
    warn "Userflags: \n";
    foreach my $f (keys %$userflags) {
	warn ":    Flag: $f  => $userflags->{$f}\n ";
    }
    return $userflags;
}


sub checkauth {
    my $query=shift;
    # $authnotrequired will be set for scripts which will run without authentication
    my $authnotrequired=shift;
    my $flagsrequired=shift;
    if (my $userid=$ENV{'REMOTE_USER'}) {
	# Using Basic Authentication, no cookies required
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return ($userid, $cookie, '');
    }
    my $sessionID=$query->cookie('sessionID');
    my $message = '';
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("select userid,ip,lasttime from sessions where sessionid=?");
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	warn "userid, ip, lasttime = ".$userid.", ".$ip.", ".$lasttime."\n";
	if ($lasttime<time()-7200) {
	    # timed logout
	    $message="You have been logged out due to inactivity.";
	    my $sti=$dbh->prepare("delete from sessions where sessionID=?");
	    $sti->execute($sessionID);
#	    my $scriptname=$ENV{'SCRIPT_NAME'};
	    my $selfurl=$query->self_url();
	    $sti=$dbh->prepare("insert into sessionqueries (sessionID, userid, url) values (?, ?, ?)");
	    $sti->execute($sessionID, $userid, $selfurl);
	    $sti->finish;
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
	    my $sth=$dbh->prepare("select cardnumber from borrowers where userid=?");
	    $sth->execute($userid);
	    my ($cardnumber) = $sth->fetchrow;
	    ($cardnumber) || ($cardnumber=$userid);
	    my $flags=getuserflags($cardnumber,$dbh);
	    my $configfile=configfile();
	    if ($userid eq $configfile->{'user'}) {
		# Super User Account from /etc/koha.conf
		$flags->{'superlibrarian'}=1;
	    }
	    foreach (keys %$flagsrequired) {
		warn "Checking required flag $_";
		unless ($flags->{superlibrarian}) {
		    unless ($flags->{$_}) {
			print qq|Content-type: text/html

<html>
<body>
REJECTED
<hr>
You do not have access to this portion of Koha
</body>
</html>
|;
			exit;
		    }
		}
	    }
	    return ($userid, $cookie, $sessionID, $flags);
	}
    }
    $sth->finish;

    if ($authnotrequired) {
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return('', $cookie, '');

    } else {
	($sessionID) || ($sessionID=int(rand()*100000).'-'.time());
	my $userid=$query->param('userid');
	my $password=$query->param('password');
	my ($return, $cardnumber) = checkpw($dbh,$userid,$password);
	if ($return) {
	    my $sti=$dbh->prepare("delete from sessions where sessionID=? and userid=?");
	    $sti->execute($sessionID, $userid);
	    $sti=$dbh->prepare("insert into sessions (sessionID, userid, ip,lasttime) values (?, ?, ?, ?)");
	    $sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
	    $sti=$dbh->prepare("select url from sessionqueries where sessionID=? and userid=?");
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
	    my $flags;
	    if ($return==2) {
		$flags->{'superlibrarian'}=1;
	    } else {
		$flags=getuserflags($cardnumber, $dbh);
	    }
	    foreach (keys %$flagsrequired) {
		warn "Checking required flag $_";
		unless ($flags->{superlibrarian}) {
		    unless ($flags->{$_}) {
			print qq|Content-type: text/html

<html>
<body>
REJECTED
<hr>
You do not have access to this portion of Koha
</body>
</html>
|;
			exit;
		    }
		}
	    }
	    return ($userid, $cookie, $sessionID, $flags);
	} else {
	    if ($userid) {
		$message="Invalid userid or password entered.";
	    }
	    my $parameters;
#	    foreach (param $query) {
#		$parameters->{$_}=$query->{$_};
#	    }
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    print $query->header(-cookie=>$cookie);
	    print qq|
<html>
<body background=/images/kohaback.jpg>
<center>
<h2>$message</h2>

<form method="post">
<table border="0" cellpadding="10" cellspacing="0" width="60%">
    <tr><td align="center" valign="top">

    <table border="0" bgcolor="#dddddd" cellpadding="10" cellspacing="0">
    <tr><th colspan="2" background="/images/background-mem.gif"><font size="+2">Koha Login</font></th></tr>
    <tr><td>Name:</td><td><input name="userid"></td></tr>
    <tr><td>Password:</td><td><input type=password name=password></td></tr>
    <tr><td colspan="2" align="center"><input type="submit" value="login"></td></tr>
    </table>
<!--
    
    </td><td align="center" valign="top">

    <table border="0" bgcolor="#dddddd" cellpadding="10" cellspacing="0">
    <tr><th background="/images/background-mem.gif"><font size="+2">Demo Information</font></th></tr>
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
    my $sth=$dbh->prepare("select password,cardnumber from borrowers where userid=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password,$cardnumber) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1,$cardnumber;
	}
    }
    my $sth=$dbh->prepare("select password from borrowers where cardnumber=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1,$userid;
	}
    }
    my $configfile=configfile();
    if ($userid eq $configfile->{'user'} && $password eq $configfile->{'pass'}) {
        # Koha superuser account
	return 2;
    }
    return 0;
}

sub getborrowernumber {
    my ($userid) = @_;
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("select borrowernumber from borrowers where userid=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($bnumber) = $sth->fetchrow;
	return $bnumber;
    }
    my $sth=$dbh->prepare("select borrowernumber from borrowers where cardnumber=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($bnumber) = $sth->fetchrow;
	return $bnumber;
    }
    return 0;
}



END { }       # module clean-up code here (global destructor)
