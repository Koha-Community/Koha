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
use C4::Circulation::Circ2;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	     &checkauth
	     &getborrowernumber
	     &get_template_and_user
);


sub get_template_and_user {
    my $in = shift;
    my $template = gettemplate($in->{'template_name'}, $in->{'type'});
    my ($user, $cookie, $sessionID, $flags)
	= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'});

    my $borrowernumber;
    if ($user) {
	$template->param(loggedinuser => $user);
	$template->param(sessionID => $sessionID);

	$borrowernumber = getborrowernumber($user);
	my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);
	my @bordat;
	$bordat[0] = $borr;
    
	$template->param(USER_INFO => \@bordat);
    }
    return ($template, $borrowernumber, $cookie);
}



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
    my $authnotrequired = shift;
    my $flagsrequired = shift;
    # state variables
    my $dbh=C4Connect();
    my $loggedin = 0;
    my %info;
    my ($userid, $cookie, $sessionID, $flags);
    my $logout = $query->param('logout.x');
    if ($userid = $ENV{'REMOTE_USER'}) {
	# Using Basic Authentication, no cookies required
	$cookie=$query->cookie(-name => 'sessionID',
			       -value => '',
			       -expires => '+1y');
	$loggedin = 1;
    } elsif ($sessionID=$query->cookie('sessionID')) {
	my ($ip , $lasttime);
	($userid, $ip, $lasttime) = $dbh->selectrow_array(
                        "SELECT userid,ip,lasttime FROM sessions WHERE sessionid=?",
							  undef, $sessionID);
	if ($logout) {
	    warn "In logout!\n";
	    # voluntary logout the user
	    $dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
	    $sessionID = undef;
	    $userid = undef;
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged out at %30s (manually).\n", $userid, $ip, $time;
	    close L;
	}
	if ($userid) {
	    if ($lasttime<time()-7200) {
		# timed logout
		$info{'timed_out'} = 1;
		$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
		$sessionID = undef;
		open L, ">>/tmp/sessionlog";
		my $time=localtime(time());
		printf L "%20s from %16s logged out at %30s (inactivity).\n", $userid, $ip, $time;
		close L;
	    } elsif ($ip ne $ENV{'REMOTE_ADDR'}) {
		# Different ip than originally logged in from
		$info{'oldip'} = $ip;
		$info{'newip'} = $ENV{'REMOTE_ADDR'};
		$info{'different_ip'} = 1;
		$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
		$sessionID = undef;
		open L, ">>/tmp/sessionlog";
		my $time=localtime(time());
		printf L "%20s from logged out at %30s (ip changed from %16s to %16s).\n", $userid, $time, $ip, $info{'newip'};
		close L;
	    } else {
		$cookie=$query->cookie(-name => 'sessionID',
				       -value => $sessionID,
				       -expires => '+1y');
		$dbh->do("UPDATE sessions SET lasttime=? WHERE sessionID=?",
			 undef, (time(), $sessionID));
		$flags = haspermission($dbh, $userid, $flagsrequired);
		if ($flags) {
		    $loggedin = 1;
		} else {
		    $info{'nopermission'} = 1;
		}
	    }
	}
    }
    unless ($userid) {
	$sessionID=int(rand()*100000).'-'.time();
	$userid=$query->param('userid');
	my $password=$query->param('password');
	my ($return, $cardnumber) = checkpw($dbh,$userid,$password);
	if ($return) {
	    $dbh->do("DELETE FROM sessions WHERE sessionID=? AND userid=?",
		     undef, ($sessionID, $userid));
	    $dbh->do("INSERT INTO sessions (sessionID, userid, ip,lasttime) VALUES (?, ?, ?, ?)",
		     undef, ($sessionID, $userid, $ENV{'REMOTE_ADDR'}, time()));
	    open L, ">>/tmp/sessionlog";
	    my $time=localtime(time());
	    printf L "%20s from %16s logged in  at %30s.\n", $userid, $ENV{'REMOTE_ADDR'}, $time;
	    close L;
	    $cookie=$query->cookie(-name => 'sessionID',
				   -value => $sessionID,
				   -expires => '+1y');
	    if ($flags = haspermission($dbh, $userid, $flagsrequired)) {
		$loggedin = 1;
	    } else {
		$info{'nopermission'} = 1;
	    }
	} else {
	    if ($userid) {
		$info{'invalid_username_or_password'} = 1;
	    }
	}
    }
    # finished authentification, now respond
    if ($loggedin || $authnotrequired) {
	# successful login
	unless ($cookie) {
	    $cookie=$query->cookie(-name => 'sessionID',
				   -value => '',
				   -expires => '+1y');
	}
	return ($userid, $cookie, $sessionID, $flags);
	exit;
    }
    # else we have a problem...
    # get the inputs from the incoming query
    my @inputs =();
    foreach my $name (param $query) {
	(next) if ($name eq 'userid' || $name eq 'password');
	my $value = $query->param($name);
	push @inputs, {name => $name , value => $value};
    }

    my $template = gettemplate("opac-auth.tmpl", "opac");
    $template->param(INPUTS => \@inputs);
    $template->param(loginprompt => 1) unless $info{'nopermission'};

    my $self_url = $query->url(-absolute => 1);
    $template->param(url => $self_url);
    $template->param(\%info);
    $cookie=$query->cookie(-name => 'sessionID',
				  -value => $sessionID,
				  -expires => '+1y');
    print $query->header(-cookie=>$cookie), $template->output;
    exit;
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
