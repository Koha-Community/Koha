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
use C4::Output;

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
    return $userflags;
}

sub haspermission {
    my ($dbh, $userid, $flagsrequired) = @_;
    my $sth=$dbh->prepare("SELECT cardnumber FROM borrowers WHERE userid=?");
    $sth->execute($userid);
    my ($cardnumber) = $sth->fetchrow;
    ($cardnumber) || ($cardnumber=$userid);
    my $flags=getuserflags($cardnumber,$dbh);
    foreach my $fl (keys %$flags){
	warn "$fl : $flags->{$fl}\n";
    }
    my $configfile=configfile();
    if ($userid eq $configfile->{'user'}) {
	# Super User Account from /etc/koha.conf
	$flags->{'superlibrarian'}=1;
    }
    return $flags if $flags->{superlibrarian};
    foreach (keys %$flagsrequired) {
	return $flags if $flags->{$_};
    }
    return 0;
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
    my $template = gettemplate("opac-auth.tmpl", "opac");
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("SELECT userid,ip,lasttime FROM sessions WHERE sessionid=?");
    warn "SessionID = $sessionID\n";
    $sth->execute($sessionID);
    if ($sth->rows) {
	my ($userid, $ip, $lasttime) = $sth->fetchrow;
	if ($lasttime<time()-7200) {
	    # timed logout
	    $template->param( message => "You have been logged out due to inactivity.");
	    my $sti=$dbh->prepare("DELETE FROM sessions WHERE sessionID=?");
	    $sti->execute($sessionID);
#	    my $scriptname=$ENV{'SCRIPT_NAME'};
	    my $selfurl=$query->self_url();
	    $sti=$dbh->prepare("INSERT INTO sessionqueries (sessionID, userid, url) VALUES (?, ?, ?)");
	    $sti->execute($sessionID, $userid, $selfurl);
	    $sti->finish;
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
	    close L;
	} elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
	    # Different ip than originally logged in from
	    my $newip=$ENV{'REMOTE_ADDR'};
	    $template->param( message => "ERROR ERROR ERROR ERROR<br>Attempt to re-use a cookie from a different ip address.<br>(authenticated from $ip, this request from $newip)");
	} else {
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');
	    my $sti=$dbh->prepare("UPDATE sessions SET lasttime=? WHERE sessionID=?");
	    $sti->execute(time(), $sessionID);

	    my $flags = haspermission($dbh, $userid, $flagsrequired);
	    warn "Flags : $flags\n";
	    if ($flags) {
		return ($userid, $cookie, $sessionID, $flags);
	    } else {
		$template->param(nopermission => 1);
		print "Content-Type: text/html\n\n", $template->output;
		exit;
	    }
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
	warn "sessionID : $sessionID";
	my $userid=$query->param('userid');
	my $password=$query->param('password');
	my ($return, $cardnumber) = checkpw($dbh,$userid,$password);
	if ($return) {
	    my $sti=$dbh->prepare("DELETE FROM sessions WHERE sessionID=? AND userid=?");
	    $sti->execute($sessionID, $userid);
	    $sti=$dbh->prepare("INSERT INTO sessions (sessionID, userid, ip,lasttime) VALUES (?, ?, ?, ?)");
	    $sti->execute($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time());
	    $sti=$dbh->prepare("SELECT url FROM sessionqueries WHERE sessionID=? AND userid=?");
	    $sti->execute($sessionID, $userid);
	    if ($sti->rows) {
		my ($selfurl) = $sti->fetchrow;
		my $stj=$dbh->prepare("DELETE FROM sessionqueries WHERE sessionID=?");
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

	    if (my $flags = haspermission($dbh, $userid, $flagsrequired)) {
		return ($userid, $cookie, $sessionID, $flags);
	    } else {
		$template->param(nopermission => 1);
		print "Content-Type: text/html\n\n", $template->output;
		exit;
	    }
	} else {
	    if ($userid) {
		$template->param(message => "Invalid userid or password entered.");
	    }
	    warn "Im in here!\n";
	    my @inputs;
	    my $self_url = $query->self_url();
	    foreach my $name (param $query) {
		(next) if ($name eq 'userid' || $name eq 'password');
		my $value = $query->param($name);
		push @inputs, {name => $name , value => $value};
	    }
	    @inputs = () unless @inputs;
	    $template->param(INPUTS => \@inputs);
	    my $cookie=$query->cookie(-name => 'sessionID',
				      -value => $sessionID,
				      -expires => '+1y');

	    $template->param(loginprompt => 1);

	    # Strip userid and password parameters off the self_url variable

	    $self_url=~s/\?*userid=[^;]*;*//g;
	    $self_url=~s/\?*password=[^;]*;*//g;

	    $template->param(url => $self_url);
	    print $query->header(-cookie=>$cookie), $template->output;
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
