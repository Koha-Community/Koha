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
use C4::Context;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;

  $query = new CGI;
  ($userid, $cookie, $sessionID) = &checkauth($query);

=head1 DESCRIPTION

This module provides authentication for Koha users.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
	     &checkauth
);

=item checkauth

  ($userid, $cookie, $sessionID) = &checkauth($query, $noauth);

Verifies that the user is authorized to run this script. Note that
C<&checkauth> will return if and only if the user is authorized, so it
should be called early on, before any unfinished operations (i.e., if
you've opened a file, then C<&checkauth> won't close it for you).

C<$query> is the CGI object for the script calling C<&checkauth>.

The C<$noauth> argument is optional. If it is set, then no
authorization is required for the script.

C<&checkauth> fetches user and session information from C<$query> and
ensures that the user is authorized to run scripts that require
authorization.

If C<$query> does not have a valid session ID associated with it
(i.e., the user has not logged in) or if the session has expired,
C<&checkauth> presents the user with a login page (from the point of
view of the original script, C<&checkauth> does not return). Once the
user has authenticated, C<&checkauth> restarts the original script
(this time, C<&checkauth> returns).

C<&checkauth> returns a user ID, a cookie, and a session ID. The
cookie should be sent back to the browser; it verifies that the user
has authenticated.

=cut
#'
# FIXME - (Or rather, proofreadme)
# As I understand it, the 'sessionqueries' table in the Koha database
# is supposed to save state while the user authenticates. If
# (re-)authentication is required, &checkauth saves the browser's
# original call to a new entry in sessionqueries, then presents a form
# for the user to authenticate. Once the user has authenticated
# visself, &checkauth retrieves the stored information from
# sessionqueries and allows the original request to proceed.
#
# One problem, however, is that sessionqueries only stores the URL,
# not the various values passed along from an HTML form. Thus, if the
# request came from a form and contains information on stuff to change
# (e.g., modify the contents of a virtual bookshelf), but the session
# has timed out, then when &checkauth finally allows the request to
# proceed, it will not contain the user's modifications. This is bad.
#
# Another problem is that entries in sessionqueries are supposed to be
# temporary, but there's no mechanism for removing them in case of
# error (e.g., the user can't remember vis password and walks away, or
# if the user's machine crashes in the middle of authentication).
#
# Perhaps a better implementation would be to use $query->param to get
# the parameter with which the original script was invoked, and pass
# that along through all of the authentication pages. That way, all of
# the pertinent information would be preserved, and the sessionqueries
# table could be removed.

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

    # Get session ID from cookie.
    my $sessionID=$query->cookie('sessionID');
	# FIXME - Error-checking: if the user isn't allowing cookies,
	# $sessionID will be undefined. Don't confuse this with an
	# expired cookie.

    my $message='';

    # Make sure the session ID is (still) good.
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select userid,ip,lasttime from sessions where sessionid=?");
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	# FIXME - Back door for tonnensen
	if ($lasttime<time()-45 && $userid ne 'tonnesen') {
	    # This session has been inactive for >45 seconds, and
	    # doesn't belong to user tonnensen. It has expired.
	    $message="You have been logged out due to inactivity.";

	    # Remove this session ID from the list of active sessions.
	    # FIXME - Ought to have a cron job clean this up as well.
	    my $sti=$dbh->prepare("delete from sessions where sessionID=?");
	    $sti->execute($sessionID);

	    # Add an entry to sessionqueries, so that we can restart
	    # the script once the user has authenticated.
	    my $scriptname=$ENV{'SCRIPT_NAME'};	# FIXME - Unused
	    my $selfurl=$query->self_url();
	    $sti=$dbh->prepare("insert into sessionqueries (sessionID, userid, value) values (?, ?, ?)");
	    $sti->execute($sessionID, $userid, $selfurl);

	    # Log the fact that someone tried to use an expired session ID.
	    # FIXME - Ought to have a better logging mechanism,
	    # ideally some wrapper that logs either to a
	    # user-specified file, or to syslog, as determined by
	    # either an entry in /etc/koha.conf, or a system
	    # preference.
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
	    close L;
	} elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
	    # This session is coming from an IP address other than the
	    # one where it was set. The user might be doing something
	    # naughty.
	    my $newip=$ENV{'REMOTE_ADDR'};

	    $message="ERROR ERROR ERROR ERROR<br>Attempt to re-use a cookie from a different ip address.<br>(authenticated from $ip, this request from $newip)";
	} else {
	    # This appears to be a valid session. Update the time
	    # stamp on it and return.
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    my $sti=$dbh->prepare("update sessions set lasttime=? where sessionID=?");
	    $sti->execute(time(), $sessionID);
	    return ($userid, $cookie, $sessionID);
	}
    }

    # If we get this far, it's because we haven't received a cookie
    # with a valid session ID. Need to start a new session and set a
    # new cookie.

    if ($authnotrequired) {
	# This script doesn't require the user to be logged in. Return
	# just the cookie, without user ID or session ID information.
	my $cookie=$query->cookie(-name => 'sessionID',
				  -value => '',
				  -expires => '+1y');
	return('', $cookie, '');
    } else {
	# This script requires authorization. Assume that we were
	# given user and password information; generate a new session.

	# Generate a new session ID.
	($sessionID) || ($sessionID=int(rand()*100000).'-'.time());
	my $userid=$query->param('userid');
	my $password=$query->param('password');
	if (checkpw($dbh, $userid, $password)) {
	    # The given password is valid

	    # Delete any old copies of this session.
	    my $sti=$dbh->prepare("delete from sessions where sessionID=? and userid=?");
	    $sti->execute($sessionID, $userid);

	    # Add this new session to the 'sessions' table.
	    $sti=$dbh->prepare("insert into sessions (sessionID, userid, ip,lasttime) values (?, ?, ?, ?)");
	    $sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());

	    # See if there's an entry for this session ID and user in
	    # the 'sessionqueries' table. If so, then use that entry
	    # to generate an HTTP redirect that'll take the user to
	    # where ve wanted to go in the first place.
	    $sti=$dbh->prepare("select value from sessionqueries where sessionID=? and userid=?");
			# FIXME - There is no sessionqueries.value
	    $sti->execute($sessionID, $userid);
	    if ($sti->rows) {
		my $stj=$dbh->prepare("delete from sessionqueries where sessionID=?");
		$stj->execute($sessionID);
		my ($selfurl) = $sti->fetchrow;
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
	    # Either we weren't given a user id and password, or else
	    # the password was invalid.

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

# checkpw
# Takes a database handle, user ID, and password, and verifies that
# the password is good. The user ID may be either a user ID or a card
# number.
# Returns 1 if the password is good, or 0 otherwise.
sub checkpw {

# This should be modified to allow a select of authentication schemes (ie LDAP)
# as well as local authentication through the borrowers tables passwd field
#
    my ($dbh, $userid, $password) = @_;
    my $sth;

    # Try the user ID.
    $sth = $dbh->prepare("select password from borrowers where userid=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1;		# The password matches
	}
    }

    # Try the card number.
    $sth = $dbh->prepare("select password from borrowers where cardnumber=?");
    $sth->execute($userid);
    if ($sth->rows) {
	my ($md5password) = $sth->fetchrow;
	if (md5_base64($password) eq $md5password) {
	    return 1;		# The password matches
	}
    }
    return 0;		# Either there's no such user, or the password
			# doesn't match.
}


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

CGI(3)

Digest::MD5(3)

=cut
