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
# use warnings; almost?
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
	$VERSION = 3.10;	# set the version for version checking
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
our %mapping  = %{$ldap->{mapping}} || (); #	or die ldapserver_error('mapping');
my @mapkeys = keys %mapping;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (  total  ): ", join ' ', @mapkeys, "\n";
@mapkeys = grep {defined $mapping{$_}->{is}} @mapkeys;
$debug and print STDERR "Got ", scalar(@mapkeys), " ldap mapkeys (populated): ", join ' ', @mapkeys, "\n";

my %config = (
	anonymous => ($ldapname and $ldappassword) ? 0 : 1,
    replicate => defined($ldap->{replicate}) ? $ldap->{replicate} : 1,  #    add from LDAP to Koha database for new user
       update => defined($ldap->{update}   ) ? $ldap->{update}    : 1,  # update from LDAP to Koha database for existing user
);

sub description ($) {
	my $result = shift or return undef;
	return "LDAP error #" . $result->code
			. ": " . $result->error_name . "\n"
			. "# " . $result->error_text . "\n";
}

sub search_method {
    my $db     = shift or return;
    my $userid = shift or return;
	my $uid_field = $mapping{userid}->{is} or die ldapserver_error("mapping for 'userid'");
	my $filter = Net::LDAP::Filter->new("$uid_field=$userid") or die "Failed to create new Net::LDAP::Filter";
    my $res = ($config{anonymous}) ? $db->bind : $db->bind($ldapname, password=>$ldappassword);
    if ($res->code) {		# connection refused
        warn "LDAP bind failed as ldapuser " . ($ldapname || '[ANONYMOUS]') . ": " . description($res);
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
    return $search;
}

sub checkpw_ldap {
    my ($dbh, $userid, $password) = @_;
    my @hosts = split(',', $prefhost);
    my $db = Net::LDAP->new(\@hosts);
	#$debug and $db->debug(5);
    my $userldapentry;
	if ( $ldap->{auth_by_bind} ) {
        my $principal_name = $ldap->{principal_name};
        if ($principal_name and $principal_name =~ /\%/) {
            $principal_name = sprintf($principal_name,$userid);
        } else {
            $principal_name = $userid;
        }
		my $res = $db->bind( $principal_name, password => $password );
        if ( $res->code ) {
            $debug and warn "LDAP bind failed as kohauser $principal_name: ". description($res);
            return 0;
        }
	} else {
        my $search = search_method($db, $userid) or return 0;   # warnings are in the sub
        $userldapentry = $search->shift_entry;
		my $cmpmesg = $db->compare( $userldapentry, attr=>'userpassword', value => $password );
		if ($cmpmesg->code != 6) {
			warn "LDAP Auth rejected : invalid password for user '$userid'. " . description($cmpmesg);
			return 0;
		}
	}

    # To get here, LDAP has accepted our user's login attempt.
    # But we still have work to do.  See perldoc below for detailed breakdown.

    my (%borrower);
	my ($borrowernumber,$cardnumber,$local_userid,$savedpw) = exists_local($userid);

    if (( $borrowernumber and $config{update}   ) or
        (!$borrowernumber and $config{replicate})   ) {
        %borrower = ldap_entry_2_hash($userldapentry,$userid);
        $debug and print STDERR "checkpw_ldap received \%borrower w/ " . keys(%borrower), " keys: ", join(' ', keys %borrower), "\n";
    }

    if ($borrowernumber) {
        if ($config{update}) { # A1, B1
            my $c2 = &update_local($local_userid,$password,$borrowernumber,\%borrower) || '';
            ($cardnumber eq $c2) or warn "update_local returned cardnumber '$c2' instead of '$cardnumber'";
        } else { # C1, D1
            # maybe update just the password?
        }
    } elsif ($config{replicate}) { # A2, C2
        $borrowernumber = AddMember(%borrower) or die "AddMember failed";
    } else {
        return 0;   # B2, D2
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
	foreach (keys %$x) {
		$memberhash{$_} = join ' ', @{$x->{$_}};	
		$debug and print STDERR sprintf("building \$memberhash{%s} = ", $_, join(' ', @{$x->{$_}})), "\n";
	}
	$debug and print STDERR "Finsihed \%memberhash has ", scalar(keys %memberhash), " keys\n",
					"Referencing \%mapping with ", scalar(keys %mapping), " keys\n";
	foreach my $key (keys %mapping) {
		my  $data = $memberhash{$mapping{$key}->{is}}; 
		$debug and printf STDERR "mapping %20s ==> %-20s (%s)\n", $key, $mapping{$key}->{is}, $data;
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
	$debug and printf STDERR "Userid '$arg' exists_local? %s\n", $sth->rows;
	($sth->rows == 1) and return $sth->fetchrow;

	$sth = $dbh->prepare("$select WHERE cardnumber=?");
	$sth->execute($arg);
	$debug and printf STDERR "Cardnumber '$arg' exists_local? %s\n", $sth->rows;
	($sth->rows == 1) and return $sth->fetchrow;
	return 0;
}

sub _do_changepassword {
    my ($userid, $borrowerid, $digest) = @_;
    $debug and print STDERR "changing local password for borrowernumber=$borrowerid to '$digest'\n";
    changepassword($userid, $borrowerid, $digest);

	# Confirm changes
	my $sth = C4::Context->dbh->prepare("SELECT password,cardnumber FROM borrowers WHERE borrowernumber=? ");
	$sth->execute($borrowerid);
	if ($sth->rows) {
		my ($md5password, $cardnum) = $sth->fetchrow;
        ($digest eq $md5password) and return $cardnum;
		warn "Password mismatch after update to cardnumber=$cardnum (borrowernumber=$borrowerid)";
		return undef;
	}
	die "Unexpected error after password update to userid/borrowernumber: $userid / $borrowerid.";
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
	_do_changepassword($userid, $borrowerid, $digest);
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
    <pass>metavore</pass>          <!-- password, if not anonymous -->
    <replicate>1</replicate>       <!-- add new users from LDAP to Koha database -->
    <update>1</update>             <!-- update existing users in Koha database -->
    <auth_by_bind>0</auth_by_bind> <!-- set to 1 to authenticate by binding instead of
                                        password comparison, e.g., to use Active Directory -->
    <principal_name>%s@my_domain.com</principal_name>
                                   <!-- optional, for auth_by_bind: a printf format to make userPrincipalName from koha userid -->
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

=head1 CONFIGURATION

Once a user has been accepted by the LDAP server, there are several possibilities for how Koha will behave, depending on 
your configuration and the presence of a matching Koha user in your local DB:

                         LOCAL_USER
 OPTION UPDATE REPLICATE  EXISTS?  RESULT
   A1      1       1        1      OK : We're updating them anyway.
   A2      1       1        0      OK : We're adding them anyway.
   B1      1       0        1      OK : We update them.
   B2      1       0        0     FAIL: We cannot add new user.
   C1      0       1        1      OK : We do nothing.  (maybe should update password?)
   C2      0       1        0      OK : We add the new user.
   D1      0       0        1      OK : We do nothing.  (maybe should update password?)
   D2      0       0        0     FAIL: We cannot add new user.

Note: failure here just means that Koha will fallback to checking the local DB.  That is, a given user could login with
their LDAP password OR their local one.  If this is a problem, then you should enable update and supply a mapping for 
password.  Then the local value will be updated at successful LDAP login and the passwords will be synced.

If you choose NOT to update local users, the borrowers table will not be affected at all.
Note that this means that patron passwords may appear to change if LDAP is ever disabled, because
the local table never contained the LDAP values.  

=head2 auth_by_bind

Binds as the user instead of retrieving their record.  Recommended if update disabled.

=head2 principal_name

Provides an optional sprintf-style format for manipulating the userid before the bind.
Even though the userPrincipalName is one intended target, any uniquely identifying
attribute that the server allows to be used for binding could be used.

Currently, principal_name only operates when auth_by_bind is enabled.

=head2 Active Directory 

The auth_by_bind and principal_name settings are recommended for Active Directory.

Under default Active Directory rules, we cannot determine the distinguishedName attribute from the Koha userid as reliably as
we would typically under openldap.  Instead of:

    distinguishedName: CN=barnes.7,DC=my_company,DC=com

We might get:

    distinguishedName: CN=Barnes\, Jim,OU=Test Accounts,OU=User Accounts,DC=my_company,DC=com

Matching that would require us to know more info about the account (firstname, surname) and to include punctuation and whitespace
in Koha userids.  But the userPrincipalName should be consistent, something like:

    userPrincipalName: barnes.7@my_company.com

Therefore it is often easier to bind to Active Directory with userPrincipalName, effectively the
canonical email address for that user, or what it would be if email were enabled for them.  If Koha userid values 
will match the username portion of the userPrincipalName, and the domain suffix is the same for all users, then use principal_name
like this:
    <principal_name>%s@core.my_company.com</principal_name>

The user of the previous example, barnes.7, would then attempt to bind as:
    barnes.7@core.my_company.com

=head1 SEE ALSO

CGI(3)

Net::LDAP()

XML::Simple()

Digest::MD5(3)

sprintf()

=cut

# For reference, here's an important difference in the data structure we rely on.
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
