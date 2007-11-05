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

use C4::Context;
use C4::Koha;
use C4::Members;
use Digest::MD5 qw(md5_base64);

our (@ISA, @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT_OK = qw(invalid_patron);

our %patron_db = (
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

sub new {
    my ($class, $patron_id) = @_;
    my $type = ref($class) || $class;
    my $self;
my %ilspatron;
	my $kp = GetMember($patron_id,'cardnumber');
warn "THIS IS what we et from getmember...";
use Data::Dumper;
warn Dumper($kp);
    if ($kp) {
	my $pw = $kp->{password};    ## FIXME - md5hash -- deal with . 
	my $dob= $kp->{dateofbirth};
	$dob =~ s/\-//g;

	my $debarred = $kp->{debarred}; ### 1 if ($kp->{flags}->{DBARRED}->{noissues});
warn "i am debarred: $debarred";
#warn Dumper(%{$kp->{flags}});
	my $adr = $kp->{streetnumber} . " ". $kp->{address}; 
		%ilspatron = (
		      name => $kp->{firstname} . " " . $kp->{surname},
		      id => $kp->{cardnumber},
		      password => $pw,
		      ptype => $kp->{categorycode}, # 'A'dult.  Whatever.
		      birthdate => $dob,
		      address => $adr,
		      home_phone => $kp->{phone},
		      email_addr => $kp->{email},
		      charge_ok => (!$debarred) , ##  (C4::Context->preference('FinesMode') eq 'charge') || 0,
		      renew_ok => 0,
			  recall_ok => 0,
		      hold_ok => 0,
		      card_lost => 0,#$kp->{flags}->{LOST},
		      claims_returned => 0,
		      fines => 0,#$kp->{flags}->{CHARGES},
		      fees => 0,
		      recall_overdue => 0,
		      items_billed => 0,
		      screen_msg => '',
		      print_line => '',
		      items => [] ,
		      hold_items => [],#$kp->{flags}->{WAITING}{itemlist}->{biblionumber},
		      overdue_items =>[], # [$kp->{flags}->{ODUES}{itemlisttext}],   ### FIXME -> this should be array, not texts string.
		      fine_items => [],
		      recall_items => [],
		      unavail_holds => [],
		      inet => 0,
			  );
	} else {
		syslog("LOG_DEBUG", "new ILS::Patron(%s): no such patron", $patron_id);
		return undef;
    }

    $self =  \%ilspatron;
	warn Dumper($self);

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
	my $md5pwd=$self->{password};  ### FIXME -  we're allowing access if user has no password.

return (!$self->{password} ||  md5_base64($pwd) eq $md5pwd );
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

    $start = 1 if !defined($start);
    $end = scalar @{$self->{hold_items}} if !defined($end);

    return [@{$self->{hold_items}}[$start-1 .. $end-1]];
}

#
# remove the hold on item item_id from my hold queue.
# return true if I was holding the item, false otherwise.
# 
sub drop_hold {
    my ($self, $item_id) = @_;
    my $i;

    for ($i = 0; $i < scalar @{$self->{hold_items}}; $i += 1) {
	if ($self->{hold_items}[$i]->{item_id} eq $item_id) {
	    splice @{$self->{hold_items}}, $i, 1;
	    return 1;
	}
    }

    return 0;
}

sub overdue_items {
    my ($self, $start, $end) = @_;

    $start = 1 if !defined($start);
    $end = scalar @{$self->{overdue_items}} if !defined($end);

    return [@{$self->{overdue_items}}[$start-1 .. $end-1]];
}

sub charged_items {
    my ($self, $start, $end) = shift;

    $start = 1 if !defined($start);
    $end = scalar @{$self->{items}} if !defined($end);

    syslog("LOG_DEBUG", "charged_items: start = %d, end = %d", $start, $end);
    syslog("LOG_DEBUG", "charged_items: items = (%s)",
	   join(', ', @{$self->{items}}));

	return [@{$self->{items}}[$start-1 .. $end-1]];
}

sub fine_items {
    my ($self, $start, $end) = @_;

    $start = 1 if !defined($start);
    $end = scalar @{$self->{fine_items}} if !defined($end);

    return [@{$self->{fine_items}}[$start-1 .. $end-1]];
}

sub recall_items {
    my ($self, $start, $end) = @_;

    $start = 1 if !defined($start);
    $end = scalar @{$self->{recall_items}} if !defined($end);

    return [@{$self->{recall_items}}[$start-1 .. $end-1]];
}

sub unavail_holds {
    my ($self, $start, $end) = @_;

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
