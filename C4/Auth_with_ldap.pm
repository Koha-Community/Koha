# -*- tab-width: 8 -*-
# NOTE: This file uses 8-character tabs; do not change the tab size!

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
use C4::Output;              # to get the template
use C4::Interface::CGI::Output;
use C4::Circulation::Circ2;  # getpatroninformation
use C4::Members;
use Net::LDAP;
use Net::LDAP qw(:all);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name   => "opac-main.tmpl",
                             query           => $query,
			     type            => "opac",
			     authnotrequired => 1,
			     flagsrequired   => {borrow => 1},
			  });

  print $query->header(
    -type => guesstype($template->output),
    -cookie => $cookie
  ), $template->output;


=head1 DESCRIPTION

    The main function of this module is to provide
    authentification. However the get_template_and_user function has
    been provided so that a users login information is passed along
    automatically. This gets loaded into the template.

=head1 LDAP specific

    This module is specific to LDAP authentification. It requires Net::LDAP package and a working LDAP server.
	To use it :
	   * move initial Auth.pm elsewhere
	   * Search the string LOCAL
	   * modify the code between LOCAL and /LOCAL to fit your LDAP server parameters & fields
	   * rename this module to Auth.pm
	That should be enough.

=head1 FUNCTIONS

=over 2

=cut



@ISA = qw(Exporter);
@EXPORT = qw(
	     &checkauth
	     &get_template_and_user
);

=item get_template_and_user

  my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name   => "opac-main.tmpl",
                             query           => $query,
			     type            => "opac",
			     authnotrequired => 1,
			     flagsrequired   => {borrow => 1},
			  });

    This call passes the C<query>, C<flagsrequired> and C<authnotrequired>
    to C<&checkauth> (in this module) to perform authentification.
    See C<&checkauth> for an explanation of these parameters.

    The C<template_name> is then used to find the correct template for
    the page. The authenticated users details are loaded onto the
    template in the HTML::Template LOOP variable C<USER_INFO>. Also the
    C<sessionID> is passed to the template. This can be used in templates
    if cookies are disabled. It needs to be put as and input to every
    authenticated page.

    More information on the C<gettemplate> sub can be found in the
    Output.pm module.

=cut


sub get_template_and_user {
	my $in = shift;
	my $template = gettemplate($in->{'template_name'}, $in->{'type'},$in->{'query'});
	my ($user, $cookie, $sessionID, $flags)
		= checkauth($in->{'query'}, $in->{'authnotrequired'}, $in->{'flagsrequired'}, $in->{'type'});

	my $borrowernumber;
	if ($user) {
		$template->param(loggedinusername => $user);
		$template->param(sessionID => $sessionID);

		$borrowernumber = getborrowernumber($user);
		my ($borr, $alternativeflags) = getpatroninformation(undef, $borrowernumber);
		my @bordat;
		$bordat[0] = $borr;
		$template->param(USER_INFO => \@bordat,
		);
		
		# We are going to use the $flags returned by checkauth
		# to create the template's parameters that will indicate
		# which menus the user can access.
		if ($flags->{superlibrarian} == 1)
		{
			$template->param(CAN_user_circulate => 1);
			$template->param(CAN_user_catalogue => 1);
			$template->param(CAN_user_parameters => 1);
			$template->param(CAN_user_borrowers => 1);
			$template->param(CAN_user_permission => 1);
			$template->param(CAN_user_reserveforothers => 1);
			$template->param(CAN_user_borrow => 1);
			$template->param(CAN_user_reserveforself => 1);
			$template->param(CAN_user_editcatalogue => 1);
			$template->param(CAN_user_updatecharge => 1);
			$template->param(CAN_user_acquisition => 1);
			$template->param(CAN_user_management => 1);
			$template->param(CAN_user_tools => 1); }
		
		if ($flags->{circulate} == 1) {
			$template->param(CAN_user_circulate => 1); }

		if ($flags->{catalogue} == 1) {
			$template->param(CAN_user_catalogue => 1); }
		
		if ($flags->{parameters} == 1) {
			$template->param(CAN_user_parameters => 1);	
			$template->param(CAN_user_management => 1);
			$template->param(CAN_user_tools => 1); }
		
		if ($flags->{borrowers} == 1) {
			$template->param(CAN_user_borrowers => 1); }
		
		if ($flags->{permissions} == 1) {
			$template->param(CAN_user_permission => 1); }
		
		if ($flags->{reserveforothers} == 1) {
			$template->param(CAN_user_reserveforothers => 1); }
		
		if ($flags->{borrow} == 1) {
			$template->param(CAN_user_borrow => 1); }
		
		if ($flags->{reserveforself} == 1) {
			$template->param(CAN_user_reserveforself => 1); }
		
		if ($flags->{editcatalogue} == 1) {
			$template->param(CAN_user_editcatalogue => 1); }
		
		if ($flags->{updatecharges} == 1) {
			$template->param(CAN_user_updatecharge => 1); }
		
		if ($flags->{acquisition} == 1) {
			$template->param(CAN_user_acquisition => 1); }
		
		if ($flags->{management} == 1) {
			$template->param(CAN_user_management => 1);
			$template->param(CAN_user_tools => 1); }
		
		if ($flags->{tools} == 1) {
			$template->param(CAN_user_tools => 1); }
		
	}
	$template->param(
			     LibraryName => C4::Context->preference("LibraryName"),
		);
	return ($template, $borrowernumber, $cookie);
}


=item checkauth

  ($userid, $cookie, $sessionID) = &checkauth($query, $noauth, $flagsrequired, $type);

Verifies that the user is authorized to run this script.  If
the user is authorized, a (userid, cookie, session-id, flags)
quadruple is returned.  If the user is not authorized but does
not have the required privilege (see $flagsrequired below), it
displays an error page and exits.  Otherwise, it displays the
login page and exits.

Note that C<&checkauth> will return if and only if the user
is authorized, so it should be called early on, before any
unfinished operations (e.g., if you've opened a file, then
C<&checkauth> won't close it for you).

C<$query> is the CGI object for the script calling C<&checkauth>.

The C<$noauth> argument is optional. If it is set, then no
authorization is required for the script.

C<&checkauth> fetches user and session information from C<$query> and
ensures that the user is authorized to run scripts that require
authorization.

The C<$flagsrequired> argument specifies the required privileges
the user must have if the username and password are correct.
It should be specified as a reference-to-hash; keys in the hash
should be the "flags" for the user, as specified in the Members
intranet module. Any key specified must correspond to a "flag"
in the userflags table. E.g., { circulate => 1 } would specify
that the user must have the "circulate" privilege in order to
proceed. To make sure that access control is correct, the
C<$flagsrequired> parameter must be specified correctly.

The C<$type> argument specifies whether the template should be
retrieved from the opac or intranet directory tree.  "opac" is
assumed if it is not specified; however, if C<$type> is specified,
"intranet" is assumed if it is not "opac".

If C<$query> does not have a valid session ID associated with it
(i.e., the user has not logged in) or if the session has expired,
C<&checkauth> presents the user with a login page (from the point of
view of the original script, C<&checkauth> does not return). Once the
user has authenticated, C<&checkauth> restarts the original script
(this time, C<&checkauth> returns).

The login page is provided using a HTML::Template, which is set in the
systempreferences table or at the top of this file. The variable C<$type>
selects which template to use, either the opac or the intranet 
authentification template.

C<&checkauth> returns a user ID, a cookie, and a session ID. The
cookie should be sent back to the browser; it verifies that the user
has authenticated.

=cut



sub checkauth {
	my $query=shift;
	# $authnotrequired will be set for scripts which will run without authentication
	my $authnotrequired = shift;
	my $flagsrequired = shift;
	my $type = shift;
	$type = 'opac' unless $type;

	my $dbh = C4::Context->dbh;
	my $timeout = C4::Context->preference('timeout');
	$timeout = 600 unless $timeout;

	my $template_name;
	if ($type eq 'opac') {
		$template_name = "opac-auth.tmpl";
	} else {
		$template_name = "auth.tmpl";
	}

	# state variables
	my $loggedin = 0;
	my %info;
	my ($userid, $cookie, $sessionID, $flags);
	my $logout = $query->param('logout.x');
	if ($userid = $ENV{'REMOTE_USER'}) {
		# Using Basic Authentication, no cookies required
		$cookie=$query->cookie(-name => 'sessionID',
				-value => '',
				-expires => '');
		$loggedin = 1;
	} elsif ($sessionID=$query->cookie('sessionID')) {
		my ($ip , $lasttime);
		($userid, $ip, $lasttime) = $dbh->selectrow_array(
				"SELECT userid,ip,lasttime FROM sessions WHERE sessionid=?",
								undef, $sessionID);
		if ($logout) {
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
		if ($lasttime<time()-$timeout) {
			# timed logout
			$info{'timed_out'} = 1;
			$dbh->do("DELETE FROM sessions WHERE sessionID=?", undef, $sessionID);
			$userid = undef;
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
			$userid = undef;
			open L, ">>/tmp/sessionlog";
			my $time=localtime(time());
			printf L "%20s from logged out at %30s (ip changed from %16s to %16s).\n", $userid, $time, $ip, $info{'newip'};
			close L;
		} else {
			$cookie=$query->cookie(-name => 'sessionID',
					-value => $sessionID,
					-expires => '');
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
					-expires => '');
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
	my $insecure = C4::Context->boolean_preference('insecure');
	# finished authentification, now respond
	if ($loggedin || $authnotrequired || (defined($insecure) && $insecure)) {
		# successful login
		unless ($cookie) {
		$cookie=$query->cookie(-name => 'sessionID',
					-value => '',
					-expires => '');
		}
		return ($userid, $cookie, $sessionID, $flags);
	}
	# else we have a problem...
	# get the inputs from the incoming query
	my @inputs =();
	foreach my $name (param $query) {
		(next) if ($name eq 'userid' || $name eq 'password');
		my $value = $query->param($name);
		push @inputs, {name => $name , value => $value};
	}

	my $template = gettemplate($template_name, $type,$query);
	$template->param(INPUTS => \@inputs);
	$template->param(loginprompt => 1) unless $info{'nopermission'};

	my $self_url = $query->url(-absolute => 1);
	$template->param(url => $self_url);
	$template->param(\%info);
	$cookie=$query->cookie(-name => 'sessionID',
					-value => $sessionID,
					-expires => '');
	print $query->header(
		-type => guesstype($template->output),
		-cookie => $cookie
		), $template->output;
	exit;
}



# this checkpw is a LDAP based one
# it connects to LDAP (anonymous)
# it retrieve $userid a-login
# then compare $password with a-weak
# then get the LDAP entry
# and calls the memberadd if necessary

sub checkpw {
	my ($dbh, $userid, $password) = @_;
	if ($userid eq C4::Context->config('user') && $password eq C4::Context->config('pass')) {
		# Koha superuser account
		return 2;
	}
	##################################################
	### LOCAL
	### Change the code below to match your own LDAP server.
	##################################################
	# LDAP connexion parameters
	my $ldapserver = 'your.ldap.server.com';
	# Infos to do an anonymous bind
	my $ldapinfos = 'a-section=people,dc=emn,dc=fr ';
	my $name  = "a-section=people,dc=emn,dc=fr";
	my $db = Net::LDAP->new( $ldapserver );
	
	# do an anonymous bind
	my $res =$db->bind();
	# check connexion
	if($res->code) {
		# auth refused
		warn "LDAP Auth impossible : server not responding";
		return 0;
	# search user
	} else {
		my $userdnsearch = $db->search(base => $name,
				filter =>"(a-login=$userid)",
				);
		if($userdnsearch->code || ! ( $userdnsearch-> count eq 1 ) ) {
			warn "LDAP Auth impossible : user unknown in LDAP";
			return 0;
		};
		# compare a-weak with $password.
		# The a-weak LDAP field contains the password
		my $userldapentry=$userdnsearch -> shift_entry;
		my $cmpmesg = $db -> compare ( $userldapentry, attr => 'a-weak', value => $password );
		if( $cmpmesg -> code != 6 ) {
			warn "LDAP Auth impossible : wrong password";
			return 0;
		};
		# build LDAP hash
		my %memberhash;
		my $x =$userldapentry->{asn}{attributes};
		my $key;
		foreach my $k ( @$x) {
			foreach my $k2 (keys %$k) {
				if ($k2 eq 'type') {
					$key = $$k{$k2};
				} else {
					my $a = @$k{$k2};
					foreach my $k3 (@$a) {
						$memberhash{$key} .= $k3." ";
					}
				}
			}
		}
		#
		# BUILD %borrower to CREATE or MODIFY BORROWER
		# change $memberhash{'xxx'} to fit your ldap structure.
		# check twice that mandatory fields are correctly filled
		#
		my %borrower;
		$borrower{cardnumber} = $userid;
		$borrower{firstname} = $memberhash{givenName}; # MANDATORY FIELD
		$borrower{surname} = $memberhash{sn}; # MANDATORY FIELD
		$borrower{initials} = substr($borrower{firstname},0,1).substr($borrower{surname},0,1)."  "; # MANDATORY FIELD
		$borrower{streetaddress} = $memberhash{l}." "; # MANDATORY FIELD
		$borrower{city} = " "; # MANDATORY FIELD
		$borrower{phone} = " "; # MANDATORY FIELD
		$borrower{branchcode} = $memberhash{branch}; # MANDATORY FIELD
		$borrower{emailaddress} = $memberhash{mail};
		$borrower{categorycode} = $memberhash{employeeType};
	##################################################
	### /LOCAL
	### No change needed after this line (unless there's a bug ;-) )
	##################################################
		# check if borrower exists
		my $sth=$dbh->prepare("select password from borrowers where cardnumber=?");
		$sth->execute($userid);
		if ($sth->rows) {
			# it exists, MODIFY
			my $sth2 = $dbh->prepare("update borrowers set firstname=?,surname=?,initials=?,streetaddress=?,city=?,phone=?, categorycode=?,branchcode=?,emailaddress=?,sort1=? where cardnumber=?");
			$sth2->execute($borrower{firstname},$borrower{surname},$borrower{initials},
							$borrower{streetaddress},$borrower{city},$borrower{phone},
							$borrower{categorycode},$borrower{branchcode},$borrower{emailaddress},
							$borrower{sort1} ,$userid);
		} else {
			# it does not exists, ADD borrower
			my $borrowerid = newmember(%borrower);
		}
		#
		# CREATE or MODIFY PASSWORD/LOGIN
		#
		# search borrowerid
		$sth = $dbh->prepare("select borrowernumber from borrowers where cardnumber=?");
		$sth->execute($userid);
		my ($borrowerid)=$sth->fetchrow;
		my $digest=md5_base64($password);
		changepassword($userid,$borrowerid,$digest);
	}

# INTERNAL AUTH. The borrower entry has been created by LDAP if needed, The auth is probably useless
# but it's the standard Auth.pm here.
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
	return 0;
}

sub getuserflags {
    my $cardnumber=shift;
    my $dbh=shift;
    my $userflags;
    my $sth=$dbh->prepare("SELECT flags FROM borrowers WHERE cardnumber=?");
    $sth->execute($cardnumber);
    my ($flags) = $sth->fetchrow;
    $sth=$dbh->prepare("SELECT bit, flag, defaulton FROM userflags");
    $sth->execute;
    while (my ($bit, $flag, $defaulton) = $sth->fetchrow) {
	if (($flags & (2**$bit)) || $defaulton) {
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
    my $configfile;
    if ($userid eq C4::Context->config('user')) {
	# Super User Account from /etc/koha.conf
	$flags->{'superlibrarian'}=1;
     }
     if ($userid eq 'demo' && C4::Context->config('demo')) {
	# Demo user that can do "anything" (demo=1 in /etc/koha.conf)
	$flags->{'superlibrarian'}=1;
    }
    return $flags if $flags->{superlibrarian};
    foreach (keys %$flagsrequired) {
	return $flags if $flags->{$_};
    }
    return 0;
}

sub getborrowernumber {
    my ($userid) = @_;
    my $dbh = C4::Context->dbh;
    for my $field ('userid', 'cardnumber') {
      my $sth=$dbh->prepare
	  ("select borrowernumber from borrowers where $field=?");
      $sth->execute($userid);
      if ($sth->rows) {
	my ($bnumber) = $sth->fetchrow;
	return $bnumber;
      }
    }
    return 0;
}

END { }       # module clean-up code here (global destructor)
1;
__END__

=back

=head1 SEE ALSO

CGI(3)

C4::Output(3)

Digest::MD5(3)

=cut
