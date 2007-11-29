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
use C4::Members qw(AddMember changepassword);
use C4::Utils qw( :all );
use Net::LDAP;
use Net::LDAP::Filter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
	$VERSION = 3.01;	# set the version for version checking
	$debug = $ENV{DEBUG} || 0;
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
	   * Modify ldapserver and ldapinfos via web "Preferences".
	   * Modify the values (right side) of %mapping pairs, to match your LDAP fields.
	   * Modify $ldapname and $ldappassword, if required.

	It is assumed your user records are stored according to the inetOrgPerson schema, RFC#2798.
	Thus the username must match the "uid" field, and the password must match the "userPassword" field.

	Make sure that the required fields are populated in your LDAP database.  What are they?  Well, in
	mysql you can check the database table "borrowers" like this:

	mysql> show COLUMNS from borrowers;
		+------------------+--------------+------+-----+---------+----------------+
		| Field            | Type         | Null | Key | Default | Extra          |
		+------------------+--------------+------+-----+---------+----------------+
		| borrowernumber   | int(11)      | NO   | PRI | NULL    | auto_increment | 
		| cardnumber       | varchar(16)  | YES  | UNI | NULL    |                | 
		| surname          | mediumtext   | NO   |     |         |                | 
		| firstname        | text         | YES  |     | NULL    |                | 
		| title            | mediumtext   | YES  |     | NULL    |                | 
		| othernames       | mediumtext   | YES  |     | NULL    |                | 
		| initials         | text         | YES  |     | NULL    |                | 
		| streetnumber     | varchar(10)  | YES  |     | NULL    |                | 
		| streettype       | varchar(50)  | YES  |     | NULL    |                | 
		| address          | mediumtext   | NO   |     |         |                | 
		| address2         | text         | YES  |     | NULL    |                | 
		| city             | mediumtext   | NO   |     |         |                | 
		| zipcode          | varchar(25)  | YES  |     | NULL    |                | 
		| email            | mediumtext   | YES  |     | NULL    |                | 
		| phone            | text         | YES  |     | NULL    |                | 
		| mobile           | varchar(50)  | YES  |     | NULL    |                | 
		| fax              | mediumtext   | YES  |     | NULL    |                | 
		| emailpro         | text         | YES  |     | NULL    |                | 
		| phonepro         | text         | YES  |     | NULL    |                | 
		| B_streetnumber   | varchar(10)  | YES  |     | NULL    |                | 
		| B_streettype     | varchar(50)  | YES  |     | NULL    |                | 
		| B_address        | varchar(100) | YES  |     | NULL    |                | 
		| B_city           | mediumtext   | YES  |     | NULL    |                | 
		| B_zipcode        | varchar(25)  | YES  |     | NULL    |                | 
		| B_email          | text         | YES  |     | NULL    |                | 
		| B_phone          | mediumtext   | YES  |     | NULL    |                | 
		| dateofbirth      | date         | YES  |     | NULL    |                | 
		| branchcode       | varchar(10)  | NO   | MUL |         |                | 
		| categorycode     | varchar(10)  | NO   | MUL |         |                | 
		| dateenrolled     | date         | YES  |     | NULL    |                | 
		| dateexpiry       | date         | YES  |     | NULL    |                | 
		| gonenoaddress    | tinyint(1)   | YES  |     | NULL    |                | 
		| lost             | tinyint(1)   | YES  |     | NULL    |                | 
		| debarred         | tinyint(1)   | YES  |     | NULL    |                | 
		| contactname      | mediumtext   | YES  |     | NULL    |                | 
		| contactfirstname | text         | YES  |     | NULL    |                | 
		| contacttitle     | text         | YES  |     | NULL    |                | 
		| guarantorid      | int(11)      | YES  |     | NULL    |                | 
		| borrowernotes    | mediumtext   | YES  |     | NULL    |                | 
		| relationship     | varchar(100) | YES  |     | NULL    |                | 
		| ethnicity        | varchar(50)  | YES  |     | NULL    |                | 
		| ethnotes         | varchar(255) | YES  |     | NULL    |                | 
		| sex              | varchar(1)   | YES  |     | NULL    |                | 
		| password         | varchar(30)  | YES  |     | NULL    |                | 
		| flags            | int(11)      | YES  |     | NULL    |                | 
		| userid           | varchar(30)  | YES  | MUL | NULL    |                | 
		| opacnote         | mediumtext   | YES  |     | NULL    |                | 
		| contactnote      | varchar(255) | YES  |     | NULL    |                | 
		| sort1            | varchar(80)  | YES  |     | NULL    |                | 
		| sort2            | varchar(80)  | YES  |     | NULL    |                | 
		+------------------+--------------+------+-----+---------+----------------+
		50 rows in set (0.01 sec)
	
		Then %mappings establishes the relationship between mysql field and LDAP attribute.

=cut

# Redefine checkauth:
# connect to LDAP (named or anonymous)
# ~ retrieves $userid from "uid"
# ~ then compares $password with userPassword 
# ~ then gets the LDAP entry
# ~ and calls the memberadd if necessary

sub ldapserver_error ($) {
	return sprintf('No ldapserver "%s" defined in KOHA_CONF: ' . $ENV{KOHA_CONF}, shift);
}

use vars qw($mapping @ldaphosts $base $ldapname $ldappassword);
my $context = C4::Context->new() 	or die 'C4::Context->new failed';
my $ldap = $context->{server}->{ldapserver} 	or die 'No "ldapserver" in server hash from KOHA_CONF: ' . $ENV{KOHA_CONF};
my $prefhost  = $ldap->{hostname}	or die ldapserver_error('hostname');
my $base      = $ldap->{base}		or die ldapserver_error('base');
$ldapname     = $ldap->{user}		or die ldapserver_error('user');
$ldappassword = $ldap->{pass}		or die ldapserver_error('pass');
our %mapping  = %{$ldap->{mapping}}	or die ldapserver_error('mapping');
my @mapkeys = keys %mapping;
print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (  total  ): ", join ' ', @mapkeys, "\n";
@mapkeys = grep {defined $mapping{$_}->{is}} @mapkeys;
print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (populated): ", join ' ', @mapkeys, "\n";

my %config = (
	anonymous => ($ldapname and $ldappassword) ? 0 : 1,
	replicate => $ldap->{replicate} || 1,		#    add from LDAP to Koha database for new user
	   update => $ldap->{update}    || 1,		# update from LDAP to Koha database for existing user
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
    my $db = Net::LDAP->new([$prefhost]);
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
		($config{replicate}) and warn "Replicating!!" and AddMember(%borrower);
	}
	return 1;
}

# Pass LDAP entry object and local cardnumber (userid).
# Returns borrower hash.
# Edit KOHA_CONF so $memberhash{'xxx'} fits your ldap structure.
# Ensure that mandatory fields are correctly filled!
#
sub ldap_entry_2_hash ($$) {
	my $userldapentry = shift;
	my %borrower = ( cardnumber => shift );
	my %memberhash;
	print "keys(\%\$userldapentry) = " . join(', ', keys %$userldapentry), "\n";
	print $userldapentry->dump();
	foreach (keys %$userldapentry) {
		print "\n\nLDAP key: $_\t", sprintf('(%s)', ref $userldapentry->{$_}), "\n";
		hashdump("LDAP key: ",$userldapentry->{$_});
	}
	warn "->{asn}->{attributes} : " . $userldapentry->{asn}->{attributes} ;
	my $x = $userldapentry->{asn}->{attributes} or return undef;
	my $key;

# asn   (HASH)
# LDAP key: ->{attributes} = ARRAY w/ 17 members.
# LDAP key: ->{attributes}->{HASH(0x9234290)} = HASH w/ 2 keys.
# LDAP key: ->{attributes}->{HASH(0x9234290)}->{type} = cn
# LDAP key: ->{attributes}->{HASH(0x9234290)}->{vals} = ARRAY w/ 3 members.
# LDAP key: ->{attributes}->{HASH(0x9234290)}->{vals}->{           sss} = sss
# LDAP key: ->{attributes}->{HASH(0x9234290)}->{vals}->{   Steve Smith} = Steve Smith
# LDAP key: ->{attributes}->{HASH(0x9234290)}->{vals}->{Steve S. Smith} = Steve S. Smith
#					$x				$anon
# LDAP key: ->{attributes}->{HASH(0x9234490)} = HASH w/ 2 keys.
# LDAP key: ->{attributes}->{HASH(0x9234490)}->{type} = o
# LDAP key: ->{attributes}->{HASH(0x9234490)}->{vals} = ARRAY w/ 1 members.
# LDAP key: ->{attributes}->{HASH(0x9234490)}->{vals}->{metavore} = metavore
#                        $x=([ cn=>['sss','Steve Smith','Steve S. Smith'], sss, o=>['metavore'], ])
# . . . . .

	foreach my $anon (@$x) {
		$key = $anon->{type} or next;
		$memberhash{$key} = join " ", @{$anon->{vals}};
	}
	foreach my $key (keys %mapping) {
		my  $data = $memberhash{$mapping{$key}->{is}}; 
		unless (defined $data) { 
			$data = $mapping{$key}->{content} || '';	# default or failsafe ''
		}
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
SET 	firstname=?,surname=?,initials=?,address=?,city=?,phone=?, categorycode=?,branchcode=?,email=?,sort1=?
WHERE 	cardnumber=?
	");
	$sth->execute(
		$borrower{firstname},    $borrower{surname},
		$borrower{initials},     $borrower{address},
		$borrower{city},         $borrower{phone},
		$borrower{categorycode}, $borrower{branchcode},
		$borrower{email}, 		 $borrower{sort1},
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

sub confirmer($$$) {
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
