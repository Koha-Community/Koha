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

use C4::Debug;
use C4::Context;
use C4::Members qw(AddMember changepassword);
use C4::Utils qw( :all );
use Net::LDAP;
use Net::LDAP::Filter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
	require Exporter;
	$VERSION = 3.03;	# set the version for version checking
	@ISA    = qw(Exporter);
	@EXPORT = qw( checkpw_ldap );
}

# Redefine checkpw_ldap:
# connect to LDAP (named or anonymous)
# ~ retrieves $userid from KOHA_CONF mapping
# ~ then compares $password with userPassword 
# ~ then gets the LDAP entry
# ~ and calls the memberadd if necessary

sub ldapserver_error ($) {
	return sprintf('No ldapserver "%s" defined in KOHA_CONF: ' . $ENV{KOHA_CONF}, shift);
}

use vars qw($mapping @ldaphosts $base $ldapname $ldappassword);
my $context = C4::Context->new() 	or die 'C4::Context->new failed';
my $ldap = C4::Context->config("ldapserver") or die 'No "ldapserver" in server hash from KOHA_CONF: ' . $ENV{KOHA_CONF};
my $prefhost  = $ldap->{hostname}	or die ldapserver_error('hostname');
my $base      = $ldap->{base}		or die ldapserver_error('base');
$ldapname     = $ldap->{user}		;
$ldappassword = $ldap->{pass}		;
our %mapping  = %{$ldap->{mapping}}	or die ldapserver_error('mapping');
my @mapkeys = keys %mapping;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (  total  ): ", join ' ', @mapkeys, "\n";
@mapkeys = grep {defined $mapping{$_}->{is}} @mapkeys;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (populated): ", join ' ', @mapkeys, "\n";

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

sub checkpw_ldap {
    my ($dbh, $userid, $password) = @_;
    my $db = Net::LDAP->new([$prefhost]);
	#$debug and $db->debug(5);
	my $uid_field = $mapping{userid}->{is} or die ldapserver_error("mapping for 'userid'");
	my $filter = Net::LDAP::Filter->new("$uid_field=$userid") or die "Failed to create new Net::LDAP::Filter";
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
	if ( $ldap->{auth_by_bind} ) {
		my $user_ldapname = $userldapentry->dn();
		my $user_db = Net::LDAP->new( [$prefhost] );
		$res = $user_db->bind( $user_ldapname, password => $password );
		if ( $res->code ) {
			$debug and warn "Bind as user failed ". description( $res );
			return 0;
		}
	} else {
		my $cmpmesg = $db->compare( $userldapentry, attr=>'userpassword', value => $password );
		if ($cmpmesg->code != 6) {
			warn "LDAP Auth rejected : invalid password for user '$userid'. " . description($cmpmesg);
			return 0;
		}
	}
	unless ($config{update} or $config{replicate}) {
		return 1;
	}
	my %borrower = ldap_entry_2_hash($userldapentry,$userid);
	$debug and print STDERR "checkpw_ldap received \%borrower w/ " . keys(%borrower), " keys: ", join(' ', keys %borrower), "\n";
	my ($borrowernumber,$cardnumber,$savedpw);
	($borrowernumber,$cardnumber,$userid,$savedpw) = exists_local($userid);
	if ($borrowernumber) {
		($config{update}   ) and my $c2 = &update_local($userid,$password,$borrowernumber,\%borrower) || '';
		($cardnumber eq $c2) or warn "update_local returned cardnumber '$c2' instead of '$cardnumber'";
	} else {
		($config{replicate}) and $borrowernumber = AddMember(%borrower);
	}
	return(1, $cardnumber);
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
	$userldapentry->exists('uid');	# This is bad, but required!  By side-effect, this initializes the attrs hash. 
	if ($debug) {
		print STDERR "\nkeys(\%\$userldapentry) = " . join(', ', keys %$userldapentry), "\n", $userldapentry->dump();
		foreach (keys %$userldapentry) {
			print STDERR "\n\nLDAP key: $_\t", sprintf('(%s)', ref $userldapentry->{$_}), "\n";
			hashdump("LDAP key: ",$userldapentry->{$_});
		}
	}
	my $x = $userldapentry->{attrs} or return undef;
	my $key;
	foreach (keys %$x) {
		$memberhash{$_} = join ' ', @{$x->{$_}};	
		$debug and print STDERR sprintf("building \$memberhash{%s} = ", $_, join(' ', @{$x->{$_}})), "\n";
	}
	$debug and print STDERR "Finsihed \%memberhash has ", scalar(keys %memberhash), " keys\n",
					"Referencing \%mapping with ", scalar(keys %mapping), " keys\n";
	foreach my $key (keys %mapping) {
		my  $data = $memberhash{$mapping{$key}->{is}}; 
		$debug and print STDERR printf "mapping %20s ==> %-20s (%s)\n", $key, $mapping{$key}->{is}, $data;
		unless (defined $data) { 
			$data = $mapping{$key}->{content} || '';	# default or failsafe ''
		}
		$borrower{$key} = ($data ne '') ? $data : ' ' ;
	}
	$borrower{initials} = $memberhash{initials} || 
		( substr($borrower{'firstname'},0,1)
  		. substr($borrower{ 'surname' },0,1)
  		. " ");
	return %borrower;
}

sub exists_local($) {
	my $arg = shift;
	my $dbh = C4::Context->dbh;
	my $select = "SELECT borrowernumber,cardnumber,userid,password FROM borrowers ";

	my $sth = $dbh->prepare("$select WHERE userid=?");	# was cardnumber=?
	$sth->execute($arg);
	$debug and print STDERR printf "Userid '$arg' exists_local? %s\n", $sth->rows;
	($sth->rows == 1) and return $sth->fetchrow;

	$sth = $dbh->prepare("$select WHERE cardnumber=?");
	$sth->execute($arg);
	$debug and print STDERR printf "Cardnumber '$arg' exists_local? %s\n", $sth->rows;
	($sth->rows == 1) and return $sth->fetchrow;
	return 0;
}

sub update_local($$$$) {
	my   $userid   = shift             or return undef;
	my   $digest   = md5_base64(shift) or return undef;
	my $borrowerid = shift             or return undef;
	my $borrower   = shift             or return undef;
	my @keys = keys %$borrower;
	my $dbh = C4::Context->dbh;
	my $query = "UPDATE  borrowers\nSET     " . 
		join(',', map {"$_=?"} @keys) .
		"\nWHERE   borrowernumber=? "; 
	my $sth = $dbh->prepare($query);
	if ($debug) {
		print STDERR $query, "\n",
			join "\n", map {"$_ = '" . $borrower->{$_} . "'"} @keys;
		print STDERR "\nuserid = $userid\n";
	}
	$sth->execute(
		((map {$borrower->{$_}} @keys), $borrowerid)
	);

	# MODIFY PASSWORD/LOGIN
	# search borrowerid
	$debug and print STDERR "changing local password for borrowernumber=$borrowerid to '$digest'\n";
	changepassword($userid, $borrowerid, $digest);

	# Confirm changes
	$sth = $dbh->prepare("SELECT password,cardnumber FROM borrowers WHERE borrowernumber=? ");
	$sth->execute($borrowerid);
	if ($sth->rows) {
		my ($md5password, $cardnum) = $sth->fetchrow;
        ($digest eq $md5password) and return $cardnum;
		warn "Password mismatch after update to cardnumber=$cardnum (borrowernumber=$borrowerid)";
		return undef;
	}
	die "Unexpected error after password update to userid/borrowernumber: $userid / $borrowerid.";
}

1;
__END__

=head1 NAME

C4::Auth - Authenticates Koha users

=head1 SYNOPSIS

  use C4::Auth_with_ldap;

=head1 LDAP Configuration

    This module is specific to LDAP authentification. It requires Net::LDAP package and one or more
	working LDAP servers.
	To use it :
	   * Modify ldapserver element in KOHA_CONF
	   * Establish field mapping in <mapping> element.

	For example, if your user records are stored according to the inetOrgPerson schema, RFC#2798,
	the username would match the "uid" field, and the password should match the "userpassword" field.

	Make sure that ALL required fields are populated by your LDAP database (and mapped in KOHA_CONF).  
	What are the required fields?  Well, in mysql you can check the database table "borrowers" like this:

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
		| userid           | varchar(30)  | YES  | MUL | NULL    |                |  # UNIQUE in next release.
		| opacnote         | mediumtext   | YES  |     | NULL    |                | 
		| contactnote      | varchar(255) | YES  |     | NULL    |                | 
		| sort1            | varchar(80)  | YES  |     | NULL    |                | 
		| sort2            | varchar(80)  | YES  |     | NULL    |                | 
		+------------------+--------------+------+-----+---------+----------------+
		50 rows in set (0.01 sec)
	
		Where Null="NO", the field is required.

=cut

=head1 KOHA_CONF and field mapping

Example XML stanza for LDAP configuration in KOHA_CONF.

 <config>
  ...
  <useldapserver>1</useldapserver>
  <!-- LDAP SERVER (optional) -->
  <ldapserver id="ldapserver">
    <hostname>localhost</hostname>
    <base>dc=metavore,dc=com</base>
    <user>cn=Manager,dc=metavore,dc=com</user>             <!-- DN, if not anonymous -->
    <pass>metavore</pass>      <!-- password, if not anonymous -->
    <replicate>1</replicate>   <!-- add new users from LDAP to Koha database -->
    <update>1</update>         <!-- update existing users in Koha database -->
    <mapping>                  <!-- match koha SQL field names to your LDAP record field names -->
      <firstname    is="givenname"      ></firstname>
      <surname      is="sn"             ></surname>
      <address      is="postaladdress"  ></address>
      <city         is="l"              >Athens, OH</city>
      <zipcode      is="postalcode"     ></zipcode>
      <branchcode   is="branch"         >MAIN</branchcode>
      <userid       is="uid"            ></userid>
      <password     is="userpassword"   ></password>
      <email        is="mail"           ></email>
      <categorycode is="employeetype"   >PT</categorycode>
      <phone        is="telephonenumber"></phone>
    </mapping> 
  </ldapserver> 
 </config>

The <mapping> subelements establish the relationship between mysql fields and LDAP attributes. The element name
is the column in mysql, with the "is" characteristic set to the LDAP attribute name.  Optionally, any content
between the element tags is taken as the default value.  In this example, the default categorycode is "PT" (for
patron).  

=cut

# ========================================
# Using attrs instead of {asn}->attributes
# ========================================
#
# 	LDAP key: ->{             cn} = ARRAY w/ 3 members.
# 	LDAP key: ->{             cn}->{           sss} = sss
# 	LDAP key: ->{             cn}->{   Steve Smith} = Steve Smith
# 	LDAP key: ->{             cn}->{Steve S. Smith} = Steve S. Smith
#
# 	LDAP key: ->{      givenname} = ARRAY w/ 1 members.
# 	LDAP key: ->{      givenname}->{Steve} = Steve
#

=head1 SEE ALSO

CGI(3)

Net::LDAP()

XML::Simple()

Digest::MD5(3)

=cut
