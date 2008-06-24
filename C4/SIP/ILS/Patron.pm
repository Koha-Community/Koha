#
# ILS::Patron.pm
# 
# A Class for hiding the ILS's concept of the patron from the OpenSIP
# system
#

package ILS::Patron;

use strict;
use warnings;
use Exporter;

use Sys::Syslog qw(syslog);
use Data::Dumper;

use C4::Debug;
use C4::Context;
use C4::Dates;
use C4::Koha;
use C4::Members;
use C4::Reserves;
use Digest::MD5 qw(md5_base64);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
	$VERSION = 2.01;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(invalid_patron);
}

our $kp;	# koha patron

sub new {
	my ($class, $patron_id) = @_;
    my $type = ref($class) || $class;
    my $self;
	$kp = GetMember($patron_id,'cardnumber');
	$debug and warn "new Patron: " . Dumper($kp);
    unless (defined $kp) {
		syslog("LOG_DEBUG", "new ILS::Patron(%s): no such patron", $patron_id);
		return undef;
	}
	$kp = GetMemberDetails(undef,$patron_id);
	$debug and warn "new Patron: " . Dumper($kp);
	my $pw = $kp->{password};    ## FIXME - md5hash -- deal with . 
	my $dob= $kp->{dateofbirth};
	my $fines_out = GetMemberAccountRecords($kp->{borrowernumber});
	my $flags = $kp->{flags}; # or warn "Warning: No flags from patron object for '$patron_id'"; 
	my $debarred = $kp->{debarred}; ### 1 if ($kp->{flags}->{DBARRED}->{noissues});
	$debug and warn "Debarred: $debarred = " . Dumper(%{$kp->{flags}});
	my %ilspatron;
	my $adr     = $kp->{streetnumber} || '';
	my $address = $kp->{address}      || ''; 
	$adr .= ($adr && $address) ? " $address" : $address;
	{
	no warnings;	# any of these $kp->{fields} being concat'd could be undef
	$dob =~ s/\-//g;
	%ilspatron = (
		name => $kp->{firstname} . " " . $kp->{surname},
		  id => $kp->{cardnumber},			# to SIP, the id is the BARCODE, not userid
		  password => $pw,
		     ptype => $kp->{categorycode}, # 'A'dult.  Whatever.
		 birthdate => $kp->{dateofbirth}, ##$dob,
		branchcode => $kp->{branchcode},
		   address => $adr,
		home_phone => $kp->{phone},
		email_addr => $kp->{email},
		 charge_ok => (!$debarred), ##  (C4::Context->preference('FinesMode') eq 'charge') || 0,
		  renew_ok => (!$debarred),
		 recall_ok => (!$debarred),
		   hold_ok => (!$debarred),
	 	 card_lost => ($kp->{lost} || $kp->{gonenoaddress} || $flags->{LOST}) ,
		claims_returned => 0,
		fines => $fines_out,
		 fees => 0,			# currently not distinct from fines
		recall_overdue => 0,
		  items_billed => 0,
		screen_msg => 'Greetings from Koha. ' . $kp->{opacnote},
		print_line => '',
		        items => [],
		   hold_items => $flags->{WAITING}{itemlist},
		overdue_items => $flags->{ODUES}{itemlist},
		   fine_items => [],
		 recall_items => [],
		unavail_holds => [],
		inet => 1,
	);
	}
	for (qw(CHARGES CREDITS GNA LOST DBARRED NOTES)) {
		($flags->{$_}) or next;
		$ilspatron{screen_msg} .= ($flags->{$_}->{message} || '') ;
		if ($flags->{$_}->{noissues}){
			$ilspatron{qw(charge_ok renew_ok recall_ok hold_ok)} = (0,0,0,0);
		}
	}

	# FIXME: populate items fine_items recall_items
#   $ilspatron{hold_items}    = (GetReservesFromBorrowernumber($kp->{borrowernumber},'F'));
	$ilspatron{unavail_holds} = [(GetReservesFromBorrowernumber($kp->{borrowernumber}))];
	my ($count,$issues) = GetPendingIssues($kp->{borrowernumber});
	$ilspatron{items} = $issues;
	$self = \%ilspatron;
	$debug and warn Dumper($self);
    syslog("LOG_DEBUG", "new ILS::Patron(%s): found patron '%s'", $patron_id,$self->{id});
    bless $self, $type;
    return $self;
}

sub id {
    my $self = shift;
    return $self->{id};
}
sub name {
    my $self = shift;
    return $self->{name};
}
sub address {
    my $self = shift;
    return $self->{address};
}
sub email_addr {
    my $self = shift;
    return $self->{email_addr};
}
sub home_phone {
    my $self = shift;
    return $self->{home_phone};
}
sub sip_birthdate {
    my $self = shift;
    return $self->{birthdate};
}
sub ptype {
    my $self = shift;
    return $self->{ptype};
}
sub language {
    my $self = shift;
    return $self->{language} || '000'; # Unspecified
}
sub charge_ok {
    my $self = shift;
    return $self->{charge_ok};
}
sub renew_ok {
    my $self = shift;
    return $self->{renew_ok};
}
sub recall_ok {
    my $self = shift;
    return $self->{recall_ok};
}
sub hold_ok {
    my $self = shift;
    return $self->{hold_ok};
}
sub card_lost {
    my $self = shift;
    return $self->{card_lost};
}
sub recall_overdue {
    my $self = shift;
    return $self->{recall_overdue};
}
sub check_password {
    my ($self, $pwd) = @_;
	my $md5pwd = $self->{password};
	# warn sprintf "check_password for %s: '%s' vs. '%s'",($self->{name}||''),($self->{password}||''),($pwd||'');
	(defined $pwd   ) or return 0;		# you gotta give me something (at least ''), or no deal
	(defined $md5pwd) or return($pwd eq '');	# if the record has a NULL password, accept '' as match
	return (md5_base64($pwd) eq $md5pwd);
}
sub currency {
    my $self = shift;
    return $self->{currency};
}
sub fee_amount {
    my $self = shift;
    return $self->{fee_amount} || undef;
}
sub screen_msg {
    my $self = shift;
    return $self->{screen_msg};
}
sub print_line {
    my $self = shift;
    return $self->{print_line};
}
sub too_many_charged {
    my $self = shift;
    return $self->{too_many_charged};
}
sub too_many_overdue {
    my $self = shift;
    return $self->{too_many_overdue};
}
sub too_many_renewal {
    my $self = shift;
    return $self->{too_many_renewal};
}
sub too_many_claim_return {
    my $self = shift;
    return $self->{too_many_claim_return};
}
sub too_many_lost {
    my $self = shift;
    return $self->{too_many_lost};
}
sub excessive_fines {
    my $self = shift;
    return $self->{excessive_fines};
}
sub excessive_fees {
    my $self = shift;
    return $self->{excessive_fees};
}
sub too_many_billed {
    my $self = shift;
    return $self->{too_many_billed};
}

#
# List of outstanding holds placed
#
sub hold_items {
    my ($self, $start, $end) = @_;
	$self->{hold_items} or return [];
    $start = 1 unless defined($start);
    $end = scalar @{$self->{hold_items}} unless defined($end);
    return [@{$self->{hold_items}}[$start-1 .. $end-1]];
}

#
# remove the hold on item item_id from my hold queue.
# return true if I was holding the item, false otherwise.
# 
sub drop_hold {
    my ($self, $item_id) = @_;
	$item_id or return undef;
	my $result = 0;
	foreach (qw(hold_items unavail_holds)) {
		$self->{$_} or next;
		for (my $i = 0; $i < scalar @{$self->{$_}}; $i++) {
			my $held_item = $self->{$_}[$i]->{item_id} or next;
			if ($held_item eq $item_id) {
				splice @{$self->{$_}}, $i, 1;
				$result++;
			}
		}
	}
    return $result;
}

sub overdue_items {
    my ($self, $start, $end) = @_;
	$self->{overdue_items} or return [];
    $start = 1 if !defined($start);
    $end = scalar @{$self->{overdue_items}} if !defined($end);
    return [@{$self->{overdue_items}}[$start-1 .. $end-1]];
}

sub charged_items {
    my ($self, $start, $end) = shift;
	$self->{items} or return [];
    $start = 1 if !defined($start);
    $end = scalar @{$self->{items}} if !defined($end);
    syslog("LOG_DEBUG", "charged_items: start = %d, end = %d; items(%s)",
			$start, $end, join(', ', @{$self->{items}}));
	return [@{$self->{items}}[$start-1 .. $end-1]];
}

sub fine_items {
    my ($self, $start, $end) = @_;
	$self->{fine_items} or return [];
    $start = 1 if !defined($start);
    $end = scalar @{$self->{fine_items}} if !defined($end);
    return [@{$self->{fine_items}}[$start-1 .. $end-1]];
}

sub recall_items {
    my ($self, $start, $end) = @_;
	$self->{recall_items} or return [];
    $start = 1 if !defined($start);
    $end = scalar @{$self->{recall_items}} if !defined($end);
    return [@{$self->{recall_items}}[$start-1 .. $end-1]];
}

sub unavail_holds {
    my ($self, $start, $end) = @_;
	$self->{unavail_holds} or return [];
    $start = 1 if !defined($start);
    $end = scalar @{$self->{unavail_holds}} if !defined($end);
    return [@{$self->{unavail_holds}}[$start-1 .. $end-1]];
}

sub block {
    my ($self, $card_retained, $blocked_card_msg) = @_;
    foreach my $field ('charge_ok', 'renew_ok', 'recall_ok', 'hold_ok') {
		$self->{$field} = 0;
    }
    $self->{screen_msg} = $blocked_card_msg || "Card Blocked.  Please contact library staff";
    return $self;
}

sub enable {
    my $self = shift;
    foreach my $field ('charge_ok', 'renew_ok', 'recall_ok', 'hold_ok') {
		$self->{$field} = 1;
    }
    syslog("LOG_DEBUG", "Patron(%s)->enable: charge: %s, renew:%s, recall:%s, hold:%s",
	   $self->{id}, $self->{charge_ok}, $self->{renew_ok},
	   $self->{recall_ok}, $self->{hold_ok});
    $self->{screen_msg} = "All privileges restored.";
    return $self;
}

sub inet_privileges {
    my $self = shift;
    return $self->{inet} ? 'Y' : 'N';
}

#
# Messages
#

sub invalid_patron {
    return "Please contact library staff";
}

sub charge_denied {
    return "Please contact library staff";
}

1;
__END__

=doc 

our %patron_example = (
		  djfiander => {
		      name => "David J. Fiander",
		      id => 'djfiander',
		      password => '6789',
		      ptype => 'A', # 'A'dult.  Whatever.
		      birthdate => '19640925',
		      address => '2 Meadowvale Dr. St Thomas, ON',
		      home_phone => '(519) 555 1234',
		      email_addr => 'djfiander@hotmail.com',
		      charge_ok => 1,
		      renew_ok => 1,
		      recall_ok => 0,
		      hold_ok => 1,
		      card_lost => 0,
		      claims_returned => 0,
		      fines => 100,
		      fees => 0,
		      recall_overdue => 0,
		      items_billed => 0,
		      screen_msg => '',
		      print_line => '',
		      items => [],
		      hold_items => [],
		      overdue_items => [],
		      fine_items => ['Computer Time'],
		      recall_items => [],
		      unavail_holds => [],
		      inet => 1,
		  },
  );

From borrowers table:
+---------------------+--------------+------+-----+
| Field               | Type         | Null | Key |
+---------------------+--------------+------+-----+
| borrowernumber      | int(11)      | NO   | PRI |
| cardnumber          | varchar(16)  | YES  | UNI |
| surname             | mediumtext   | NO   |     |
| firstname           | text         | YES  |     |
| title               | mediumtext   | YES  |     |
| othernames          | mediumtext   | YES  |     |
| initials            | text         | YES  |     |
| streetnumber        | varchar(10)  | YES  |     |
| streettype          | varchar(50)  | YES  |     |
| address             | mediumtext   | NO   |     |
| address2            | text         | YES  |     |
| city                | mediumtext   | NO   |     |
| zipcode             | varchar(25)  | YES  |     |
| email               | mediumtext   | YES  |     |
| phone               | text         | YES  |     |
| mobile              | varchar(50)  | YES  |     |
| fax                 | mediumtext   | YES  |     |
| emailpro            | text         | YES  |     |
| phonepro            | text         | YES  |     |
| B_streetnumber      | varchar(10)  | YES  |     |
| B_streettype        | varchar(50)  | YES  |     |
| B_address           | varchar(100) | YES  |     |
| B_city              | mediumtext   | YES  |     |
| B_zipcode           | varchar(25)  | YES  |     |
| B_email             | text         | YES  |     |
| B_phone             | mediumtext   | YES  |     |
| dateofbirth         | date         | YES  |     |
| branchcode          | varchar(10)  | NO   | MUL |
| categorycode        | varchar(10)  | NO   | MUL |
| dateenrolled        | date         | YES  |     |
| dateexpiry          | date         | YES  |     |
| gonenoaddress       | tinyint(1)   | YES  |     |
| lost                | tinyint(1)   | YES  |     |
| debarred            | tinyint(1)   | YES  |     |
| contactname         | mediumtext   | YES  |     |
| contactfirstname    | text         | YES  |     |
| contacttitle        | text         | YES  |     |
| guarantorid         | int(11)      | YES  |     |
| borrowernotes       | mediumtext   | YES  |     |
| relationship        | varchar(100) | YES  |     |
| ethnicity           | varchar(50)  | YES  |     |
| ethnotes            | varchar(255) | YES  |     |
| sex                 | varchar(1)   | YES  |     |
| password            | varchar(30)  | YES  |     |
| flags               | int(11)      | YES  |     |
| userid              | varchar(30)  | YES  | MUL |
| opacnote            | mediumtext   | YES  |     |
| contactnote         | varchar(255) | YES  |     |
| sort1               | varchar(80)  | YES  |     |
| sort2               | varchar(80)  | YES  |     |
| altcontactfirstname | varchar(255) | YES  |     |
| altcontactsurname   | varchar(255) | YES  |     |
| altcontactaddress1  | varchar(255) | YES  |     |
| altcontactaddress2  | varchar(255) | YES  |     |
| altcontactaddress3  | varchar(255) | YES  |     |
| altcontactzipcode   | varchar(50)  | YES  |     |
| altcontactphone     | varchar(50)  | YES  |     |
+---------------------+--------------+------+-----+

From C4::Members

$flags->{KEY}
{CHARGES}
	{message}     Message showing patron's credit or debt
	{noissues}    Set if patron owes >$5.00
{GNA}         	Set if patron gone w/o address
	{message}     "Borrower has no valid address"
	{noissues}    Set.
{LOST}        	Set if patron's card reported lost
	{message}     Message to this effect
	{noissues}    Set.
{DBARRED}     	Set if patron is debarred
	{message}     Message to this effect
	{noissues}    Set.
{NOTES}       	Set if patron has notes
	{message}     Notes about patron
{ODUES}       	Set if patron has overdue books
	{message}     "Yes"
	{itemlist}    ref-to-array: list of overdue books
	{itemlisttext}    Text list of overdue items
{WAITING}     	Set if there are items available that the patron reserved
	{message}     Message to this effect
	{itemlist}    ref-to-array: list of available items

=cut

