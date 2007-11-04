package C4::Auth_with_ldap;

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

use C4::Context;
use C4::Members qw(AddMember );

use Net::LDAP;
use Net::LDAP::Filter;
# use Net::LDAP qw(:all);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	require Exporter;
	$VERSION = 3.01;	# set the version for version checking
	our $debug = $ENV{DEBUG} || 0;
	@ISA    = qw(Exporter C4::Auth);
	@EXPORT = qw( checkauth );
}

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use C4::Auth_with_ldap;

=head1 LDAP specific

    This module is specific to LDAP authentification. It requires Net::LDAP package and one or more
	working LDAP servers.
	To use it :
	   * modify the code between LOCAL and /LOCAL to fit your LDAP server parameters & fields.

	It is assumed your user records are stored according to the inetOrgPerson schema, RFC#2798.
	Thus the username must match the "uid" field, and the password must match the "userPassword" field.

=cut

# Redefine checkauth:
# connect to LDAP (named or anonymous)
# ~ retrieves $userid from "uid"
# ~ then compares $password with userPassword 
# ~ then gets the LDAP entry
# ~ and calls the memberadd if necessary

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

my (@ldaphosts) = (qw(localhost));		# potentially multiple LDAP hosts!
my $base = "dc=metavore,dc=com";
my $ldapname = "cn=Manager,$base";		# The LDAP user.
my $ldappassword = 'metavore';

my %config = (
	anonymous => ($ldapname and $ldappassword) ? 0 : 1,
	replicate => 0,		#    add from LDAP to Koha database for new user
	   update => 0,		# update from LDAP to Koha database for existing user
);

sub description ($) {
	my $result = shift or return undef;
	return "LDAP error #" . $result->code
			. ": " . $result->error_name . "\n"
			. "# " . $result->error_text . "\n";
}

sub checkauth {
    my ($dbh, $userid, $password) = @_;
    if (   $userid   eq C4::Context->config('user')
        && $password eq C4::Context->config('pass') )
    {
        return 2;	# Koha superuser account
    }
    my $db = Net::LDAP->new(\@ldaphosts);
	#$debug and $db->debug(5);
	my $filter = Net::LDAP::Filter->new("uid=$userid") or die "Failed to create new Net::LDAP::Filter";
    my $res = ($config{anonymous}) ? $db->bind : $db->bind($ldapname, password=>$ldappassword);
    if ($res->code) {		# connection refused
        warn "LDAP bind failed as $ldapname: " . description($res);
        return 0;
    }
	my $search = $db->search(
		  base => $base,
	 	filter => $filter,
		# attrs => ['*'],
	) or die "LDAP search failed to return object.";
	my $count = $search->count;
	if ($search->code > 0) {
		warn sprintf("LDAP Auth rejected : %s gets %d hits\n", $filter->as_string, $count) . description($search);
		return 0;
	}
	if ($count != 1) {
		warn sprintf("LDAP Auth rejected : %s gets %d hits\n", $filter->as_string, $count);
		return 0;
	}

	my $userldapentry = $search->shift_entry;
	my $cmpmesg = $db->compare( $userldapentry, attr=>'userPassword', value => $password );
	if($cmpmesg->code != 6) {
		warn "LDAP Auth rejected : invalid password for user '$userid'. " . description($cmpmesg);
		return 0;
	}
	unless($config{update} or $config{replicate}) {
		return 1;
	}
	my %borrower = ldap_entry_2_hash($userldapentry,$userid);
	if (exists_local($userid)) {
		($config{update}   ) and &update_local($userid,$password,%borrower);
	} else {
		($config{replicate}) and AddMember(%borrower);
	}
	return 1;
}

# Pass LDAP entry object and local cardnumber (userid).
# Returns borrower hash.
# Edit %mapping so $memberhash{'xxx'} fits your ldap structure.
# Ensure that mandatory fields are correctly filled!
#
sub ldap_entry_2_hash ($$) {
	my $userldapentry = shift;
	my %borrower = ( cardnumber => shift );
	my %memberhash;
	my $x = $userldapentry->{asn}{attributes} or return undef;
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
	foreach my $key (%mapping) {
		my $data = $memberhash{$mapping{$key}}; 
		defined $data or $data = ' ';
		$borrower{$key} = ($data ne '') ? $data : ' ' ;
	}
	$borrower{initials} = $memberhash{initials} || 
		( substr($borrower{'firstname'},0,1)
  		. substr($borrower{ 'surname' },0,1)
  		. "  ");
	return %borrower;
}

sub exists_local($) {
	my $sth = C4::Context->dbh->prepare("SELECT password from borrowers WHERE cardnumber=?");
	$sth->execute(shift);
	return ($sth->rows) ? 1 : 0 ;
}

sub update_local($$%) {
	# warn "MODIFY borrower";
	my   $userid = shift or return undef;
	my   $digest = md5_base64(shift) or return undef;
	my %borrower = shift or return undef;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("
UPDATE	borrowers 
SET 	firstname=?,surname=?,initials=?,streetaddress=?,city=?,phone=?, categorycode=?,branchcode=?,emailaddress=?,sort1=?
WHERE 	cardnumber=?
	");
	$sth->execute(
		$borrower{firstname},    $borrower{surname},
		$borrower{initials},     $borrower{streetaddress},
		$borrower{city},         $borrower{phone},
		$borrower{categorycode}, $borrower{branchcode},
		$borrower{emailaddress}, $borrower{sort1},
		$userid
	);

	# MODIFY PASSWORD/LOGIN
	# search borrowerid
	$sth = $dbh->prepare("SELECT borrowernumber from borrowers WHERE cardnumber=? ");
	$sth->execute($userid);
	my ($borrowerid) = $sth->fetchrow;
	# warn "change local password for $borrowerid setting $password";
	changepassword($userid, $borrowerid, $digest);

	# Confirm changes
	my $cardnumber;
	$sth = $dbh->prepare("SELECT password,cardnumber from borrowers WHERE userid=? ");
	$cardnumber = confirmer($sth,$userid,$digest) and return $cardnumber;
    $sth = $dbh->prepare("SELECT password,cardnumber from borrowers WHERE cardnumber=? ");
	$cardnumber = confirmer($sth,$userid,$digest) and return $cardnumber;
	die "Unexpected error after password update to $userid / $cardnumber.";
}

sub confirmer($$) {
	my    $sth = shift or return undef;
	my $userid = shift or return undef;
	my $digest = shift or return undef;
	$sth->execute($userid);
	if ($sth->rows) {
		my ($md5password, $othernum) = $sth->fetchrow;
        ($digest eq $md5password) and return $othernum;
		warn "Password mismatch after update to userid=$userid";
		return undef;
    }
	warn "Could not recover record after updating password for userid=$userid";
	return 0;
}
1;
__END__

=back

=head1 SEE ALSO

CGI(3)

Net::LDAP()

Digest::MD5(3)

=cut
