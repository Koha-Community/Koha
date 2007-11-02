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
use C4::Output;    # to get the template
use C4::Members;

use Net::LDAP;
# use Net::LDAP qw(:all);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	$VERSION = 3.01;	# set the version for version checking
	@ISA    = qw(Exporter C4::Auth);
	@EXPORT = qw(&checkauth &get_template_and_user);
}

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use CGI;
  use C4::Auth;

  my $query = new CGI;

  my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({
				template_name   => "opac-main.tmpl",
				query           => $query,
				type            => "opac",
				authnotrequired => 1,
				flagsrequired   => {circulate => 1},
			  });

  print $query->header(
    -type => 'utf-8',
    -cookie => $cookie
  ), $template->output;

=head1 LDAP specific

    This module is specific to LDAP authentification. It requires Net::LDAP package and a working LDAP server.
	To use it :
	   * move initial Auth.pm elsewhere
	   * Search the string LOCAL
	   * modify the code between LOCAL and /LOCAL to fit your LDAP server parameters & fields
	   * rename this module to Auth.pm
	That should be enough.

=head1 FUNCTIONS

=cut

# Redefine checkpw
# connects to LDAP (anonymous)
# retrieves $userid a-login
# then compares $password with a-weak
# then gets the LDAP entry
# and calls the memberadd if necessary

my %mapping = (
	firstname     => 'givenName',
	surname       => 'sn',
	streetaddress => 'l',
	branchcode    => 'branch',
	emailaddress  => 'mail',
	categorycode  => 'employeeType',
	city          => 'null',
	phone         => 'telephoneNumber',
);

sub checkpw {
    my ($dbh, $userid, $password) = @_;
    if (   $userid   eq C4::Context->config('user')
        && $password eq C4::Context->config('pass') )
    {
        return 2;	# Koha superuser account
    }
    ##################################################
    ### LOCAL
    ### Change the code below to match your own LDAP server.
    ##################################################
    # LDAP connexion parameters
    my $ldapserver = 'localhost';

    # Infos to do an anonymous bind
    my $name = "dc=metavore,dc=com";
    my $db   = Net::LDAP->new($ldapserver);

    # do an anonymous bind
    my $res = $db->bind();
    if ($res->code) {		# auth refused
        warn "LDAP Auth impossible : server not responding";
        return 0;
    }
	my $userdnsearch = $db->search(
		base   => $name,
		filter => "(a-login=$userid)",
	);
	if ( $userdnsearch->code || !( $userdnsearch->count eq 1 ) ) {
		warn "LDAP Auth rejected : user unknown in LDAP";
		return 0;
	}

	my $userldapentry = $userdnsearch->shift_entry;
	my $cmpmesg = $db->compare( $userldapentry, attr => 'a-weak', value => $password );
	if($cmpmesg->code != 6) {
		warn "LDAP Auth rejected : wrong password";
		return 0;
	}

	# build LDAP hash
	my %memberhash;
	my $x = $userldapentry->{asn}{attributes};
	my $key;
	foreach my $k (@$x) {
		foreach my $k2 ( keys %$k ) {
			if ($k2 eq 'type') {
				$key = $$k{$k2};
			} else {
				$memberhash{$key} .= map {$_ . " "} @$k{$k2};
			}
		}
	}

	# BUILD %borrower to CREATE or MODIFY BORROWER
	# change $memberhash{'xxx'} to fit your ldap structure.
	# check twice that mandatory fields are correctly filled
	#
	my %borrower;
	$borrower{cardnumber} = $userid;
	foreach my $key (%mapping) {
		my $data = $memberhash{$mapping{$key}}; 
		defined $data or $data = ' ';
		$borrower{$key} = ($data ne '') ? $data : ' ' ;
	}
	$borrower{initials}   =
		substr( $borrower{firstname}, 0, 1 )
  		. substr( $borrower{surname}, 0, 1 )
  		. "  ";                                          # MANDATORY FIELD
##################################################
### /LOCAL
##################################################
# check if borrower exists (then modify, else add)
	my $sth =
	$dbh->prepare("select password from borrowers where cardnumber=?");
	$sth->execute($userid);
	if ( $sth->rows ) {
		# 	warn "MODIFY borrower";
		my $sth2 = $dbh->prepare("
UPDATE borrowers set firstname=?,surname=?,initials=?,streetaddress=?,city=?,phone=?, categorycode=?,branchcode=?,emailaddress=?,sort1=?
WHERE cardnumber=?
		");
		$sth2->execute(
			$borrower{firstname},    $borrower{surname},
			$borrower{initials},     $borrower{streetaddress},
			$borrower{city},         $borrower{phone},
			$borrower{categorycode}, $borrower{branchcode},
			$borrower{emailaddress}, $borrower{sort1},
			$userid
		);
	} else {
		# 	warn "ADD borrower";
		my $borrowerid = newmember(%borrower);
	}

	# CREATE or MODIFY PASSWORD/LOGIN
	# search borrowerid
	$sth = $dbh->prepare("SELECT borrowernumber from borrowers WHERE cardnumber=?");
	$sth->execute($userid);
	my ($borrowerid) = $sth->fetchrow;

	# 		warn "change password for $borrowerid setting $password";
		my $digest = md5_base64($password);
		changepassword( $userid, $borrowerid, $digest );

	# INTERNAL AUTH
	$sth = $dbh->prepare("SELECT password,cardnumber from borrowers WHERE userid=?");
	$sth->execute($userid);
	if ( $sth->rows ) {
		my ( $md5password, $cardnumber ) = $sth->fetchrow;
        if ( md5_base64($password) eq $md5password ) {
            return 1, $cardnumber;
        }
    }
    $sth = $dbh->prepare("SELECT password from borrowers WHERE cardnumber=?");
    $sth->execute($userid);
    if ($sth->rows) {
        my ($md5password) = $sth->fetchrow;
        if ( md5_base64($password) eq $md5password ) {
            return 1, $userid;
        }
    }
    return 0;
}

END { }    # module clean-up code here (global destructor)
1;
__END__

=back

=head1 SEE ALSO

CGI(3)

C4::Output(3)

Digest::MD5(3)

=cut
