#
# ILS.pm: Test ILS interface module
#

package OpenILS::SIP;
use warnings; use strict;

use Sys::Syslog qw(syslog);

use OpenILS::SIP::Item;
use OpenILS::SIP::Patron;
use OpenILS::SIP::Transaction;
use OpenILS::SIP::Transaction::Checkout;
use OpenILS::SIP::Transaction::Checkin;
use OpenILS::SIP::Transaction::Renew;

use OpenSRF::System;
use OpenILS::Utils::Fieldmapper;
use OpenSRF::Utils::SettingsClient;
use OpenILS::Application::AppUtils;
use OpenSRF::Utils qw/:datetime/;
use DateTime::Format::ISO8601;
my $U = 'OpenILS::Application::AppUtils';

my $editor;
my $config;

use Digest::MD5 qw(md5_hex);

sub new {
	my ($class, $institution, $login) = @_;
	my $type = ref($class) || $class;
	my $self = {};

	$self->{login} = $login;

	$config = $institution;
	syslog("LOG_DEBUG", "OILS: new ILS '%s'", $institution->{id});
	$self->{institution} = $institution;

	my $bsconfig = $institution->{implementation_config}->{bootstrap};

	syslog('LOG_DEBUG', "OILS: loading bootstrap config: $bsconfig");
	
	local $/ = "\n";
	OpenSRF::System->bootstrap_client(config_file => $bsconfig);
	syslog('LOG_DEBUG', "OILS: bootstrap loaded..");

	$self->{osrf_config} = OpenSRF::Utils::SettingsClient->new;

	Fieldmapper->import($self->{osrf_config}->config_value('IDL'));

	bless( $self, $type );

	return undef unless 
		$self->login( $login->{id}, $login->{password} );

	return $self;
}

sub verify_session {
	my $self = shift;
	my $ses = $U->simplereq( 
		'open-ils.auth',
		'open-ils.auth.session.retrieve',  $self->{authtoken} );
	return 1 unless $U->event_code($ses);
	syslog('LOG_INFO', "OILS: Logging back after session timeout as user ".$self->{login}->{id});
	return $self->login( $self->{login}->{id}, $self->{login}->{password} );
}

sub to_bool {
	my $val = shift;
	return ($val and $val =~ /true/io);
}

sub editor {
	return $editor 
		if $editor and $editor->{session}
		and $editor->session->connected;
	return $editor = make_editor();
}

sub reset_editor {
	$editor = undef;
	return editor();
}

sub config {
	return $config;
}


# Creates the global editor object
sub make_editor {
	require OpenILS::Utils::CStoreEditor;
	my $e = OpenILS::Utils::CStoreEditor->new(xact => 1);
	# gnarly cstore hack to re-gen autogen methods after IDL is loaded
	if(!UNIVERSAL::can($e, 'search_actor_card')) {
		syslog("LOG_WARNING", "OILS: Reloading CStoreEditor...");
		delete $INC{'OpenILS/Utils/CStoreEditor.pm'};
		require OpenILS::Utils::CStoreEditor;
		$e = OpenILS::Utils::CStoreEditor->new(xact =>1);
	}
	return $e;
}

sub format_date {
	my $class = shift;
	my $date = shift;
	my $type = shift || 'dob';

	return "" unless $date;

	$date = DateTime::Format::ISO8601->new->
		parse_datetime(OpenSRF::Utils::clense_ISO8601($date));
	my @time = localtime($date->epoch);

	my $year = $time[5]+1900;
	my $mon = $time[4]+1;
	my $day = $time[3];

	$mon =~ s/^(\d)$/0$1/;
	$day =~ s/^(\d)$/0$1/;
	$date = "$year$mon$day";

	$date = $year.'-'.$mon.'-'.$day .' 00:00:00' if $type eq 'due';
	#$date = $year.'-'.$mon.'-'.$day if $type eq 'due';

	syslog('LOG_DEBUG', "OILS: formatted date [type=$type]: $date");
	return $date;
}



sub login {
	my( $self, $username, $password ) = @_;
	syslog('LOG_DEBUG', "OILS: Logging in with username $username");

	my $seed = $U->simplereq( 
		'open-ils.auth',
		'open-ils.auth.authenticate.init', $username );

	my $response = $U->simplereq(
		'open-ils.auth', 
		'open-ils.auth.authenticate.complete', 
		{	
			username => $username, 
			password => md5_hex($seed . md5_hex($password)), 
			type		=> 'opac',
		}
	);

	if( my $code = $U->event_code($response) ) {
		my $txt = $response->{textcode};
		syslog('LOG_WARNING', "OILS: Login failed for $username.  $txt:$code");
		return undef;
	}

	my $key = $response->{payload}->{authtoken};
	syslog('LOG_INFO', "OILS: Login succeeded for $username : authkey = $key");
	return $self->{authtoken} = $key;
}


sub find_patron {
	my $self = shift;
	return OpenILS::SIP::Patron->new(@_);
}


sub find_item {
	my $self = shift;
	return OpenILS::SIP::Item->new(@_);
}


sub institution {
    my $self = shift;
    return $self->{institution}->{id};
}

sub supports {
	my ($self, $op) = @_;
	my ($i) = grep { $_->{name} eq $op }  
		@{$config->{implementation_config}->{supports}->{item}};
	return to_bool($i->{value});
}

sub check_inst_id {
	my ($self, $id, $whence) = @_;
	if ($id ne $self->{institution}->{id}) {
		syslog("LOG_WARNING", 
			"OILS: %s: received institution '%s', expected '%s'",
			$whence, $id, $self->{institution}->{id});
	}
}

sub checkout_ok {
	return to_bool($config->{policy}->{checkout});
}

sub checkin_ok {
	return to_bool($config->{policy}->{checkin});
    return 0;
}

sub renew_ok {
	return to_bool($config->{policy}->{renew});
}

sub status_update_ok {
	return to_bool($config->{policy}->{status_update});
}

sub offline_ok {
	return to_bool($config->{policy}->{offline});
}



##
## Checkout(patron_id, item_id, sc_renew):
##    patron_id & item_id are the identifiers send by the terminal
##    sc_renew is the renewal policy configured on the terminal
## returns a status opject that can be queried for the various bits
## of information that the protocol (SIP or NCIP) needs to generate
## the response.
##

sub checkout {
	my ($self, $patron_id, $item_id, $sc_renew) = @_;

	$self->verify_session;
	
	syslog('LOG_DEBUG', "OILS: OpenILS::Checkout attempt: patron=$patron_id, item=$item_id");
	
	my $xact		= OpenILS::SIP::Transaction::Checkout->new( authtoken => $self->{authtoken} );
	my $patron	= $self->find_patron($patron_id);
	my $item		= $self->find_item($item_id);
	
	$xact->patron($patron);
	$xact->item($item);

	if (!$patron) {
		$xact->screen_msg("Invalid Patron");
		return $xact;
	}

	if (!$patron->charge_ok) {
		$xact->screen_msg("Patron Blocked");
		return $xact;
	}

	if( !$item ) {
		$xact->screen_msg("Invalid Item");
		return $xact;
	}

	syslog('LOG_DEBUG', "OILS: OpenILS::Checkout data loaded OK, checking out...");
	$xact->do_checkout();

	if ($item->{patron} && ($item->{patron} ne $patron_id)) {
		# I can't deal with this right now
		# XXX check in then check out?
		$xact->screen_msg("Item checked out to another patron");
		$xact->ok(0);
	} 

	$xact->desensitize(!$item->magnetic);

	if( $xact->ok ) {

		#editor()->commit;
		syslog("LOG_DEBUG", "OILS: OpenILS::Checkout: " .
			"patron %s checkout %s succeeded", $patron_id, $item_id);

	} else {

		#editor()->xact_rollback;
		syslog("LOG_DEBUG", "OILS: OpenILS::Checkout: " .
			"patron %s checkout %s FAILED, rolling back xact...", $patron_id, $item_id);
	}

	return $xact;
}


sub checkin {
	my ($self, $item_id, $trans_date, $return_date,
	$current_loc, $item_props, $cancel) = @_;

	$self->verify_session;

	syslog('LOG_DEBUG', "OILS: OpenILS::Checkin on item=$item_id");
	
	my $patron;
	my $xact		= OpenILS::SIP::Transaction::Checkin->new(authtoken => $self->{authtoken});
	my $item		= $self->find_item($item_id);

	$xact->item($item);

	if(!$xact->item) {
		$xact->screen_msg("Invalid item barcode: $item_id");
		$xact->ok(0);
		return $xact;
	}

	$xact->do_checkin( $trans_date, $return_date, $current_loc, $item_props );
	
	if ($xact->ok) {

		$xact->patron($patron = $self->find_patron($item->{patron}));
		delete $item->{patron};
		delete $item->{due_date};
		syslog('LOG_INFO', "OILS: Checkin succeeded");
		#editor()->commit;

	} else {

		#editor()->xact_rollback;
		syslog('LOG_WARNING', "OILS: Checkin failed");
	}
	# END TRANSACTION

	return $xact;
}

## If the ILS caches patron information, this lets it free it up
sub end_patron_session {
    my ($self, $patron_id) = @_;
    return (1, 'Thank you for using OpenILS!', '');
}


#sub pay_fee {
#    my ($self, $patron_id, $patron_pwd, $fee_amt, $fee_type,
#	$pay_type, $fee_id, $trans_id, $currency) = @_;
#    my $trans;
#    my $patron;
#
#    $trans = new ILS::Transaction::FeePayment;
#
#    $patron = new ILS::Patron $patron_id;
#
#    $trans->transaction_id($trans_id);
#    $trans->patron($patron);
#    $trans->ok(1);
#
#    return $trans;
#}
#
#sub add_hold {
#    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
#	$expiry_date, $pickup_location, $hold_type, $fee_ack) = @_;
#    my ($patron, $item);
#    my $hold;
#    my $trans;
#
#
#    $trans = new ILS::Transaction::Hold;
#
#    # BEGIN TRANSACTION
#    $patron = new ILS::Patron $patron_id;
#    if (!$patron
#	|| (defined($patron_pwd) && !$patron->check_password($patron_pwd))) {
#	$trans->screen_msg("Invalid Patron.");
#
#	return $trans;
#    }
#
#    $item = new ILS::Item ($item_id || $title_id);
#    if (!$item) {
#	$trans->screen_msg("No such item.");
#
#	# END TRANSACTION (conditionally)
#	return $trans;
#    } elsif ($item->fee && ($fee_ack ne 'Y')) {
#	$trans->screen_msg = "Fee required to place hold.";
#
#	# END TRANSACTION (conditionally)
#	return $trans;
#    }
#
#    $hold = {
#	item_id         => $item->id,
#	patron_id       => $patron->id,
#	expiration_date => $expiry_date,
#	pickup_location => $pickup_location,
#	hold_type       => $hold_type,
#    };
#
#    $trans->ok(1);
#    $trans->patron($patron);
#    $trans->item($item);
#    $trans->pickup_location($pickup_location);
#
#    push(@{$item->hold_queue}, $hold);
#    push(@{$patron->{hold_items}}, $hold);
#
#
#    # END TRANSACTION
#    return $trans;
#}
#
#sub cancel_hold {
#    my ($self, $patron_id, $patron_pwd, $item_id, $title_id) = @_;
#    my ($patron, $item, $hold);
#    my $trans;
#
#    $trans = new ILS::Transaction::Hold;
#
#    # BEGIN TRANSACTION
#    $patron = new ILS::Patron $patron_id;
#    if (!$patron) {
#	$trans->screen_msg("Invalid patron barcode.");
#
#	return $trans;
#    } elsif (defined($patron_pwd) && !$patron->check_password($patron_pwd)) {
#	$trans->screen_msg('Invalid patron password.');
#
#	return $trans;
#    }
#
#    $item = new ILS::Item ($item_id || $title_id);
#    if (!$item) {
#	$trans->screen_msg("No such item.");
#
#	# END TRANSACTION (conditionally)
#	return $trans;
#    }
#
#    # Remove the hold from the patron's record first
#    $trans->ok($patron->drop_hold($item_id));
#
#    if (!$trans->ok) {
#	# We didn't find it on the patron record
#	$trans->screen_msg("No such hold on patron record.");
#
#	# END TRANSACTION (conditionally)
#	return $trans;
#    }
#
#    # Now, remove it from the item record.  If it was on the patron
#    # record but not on the item record, we'll treat that as success.
#    foreach my $i (0 .. scalar @{$item->hold_queue}) {
#	$hold = $item->hold_queue->[$i];
#
#	if ($hold->{patron_id} eq $patron->id) {
#	    # found it: delete it.
#	    splice @{$item->hold_queue}, $i, 1;
#	    last;
#	}
#    }
#
#    $trans->screen_msg("Hold Cancelled.");
#    $trans->patron($patron);
#    $trans->item($item);
#
#    return $trans;
#}
#
#
## The patron and item id's can't be altered, but the
## date, location, and type can.
#sub alter_hold {
#    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
#	$expiry_date, $pickup_location, $hold_type, $fee_ack) = @_;
#    my ($patron, $item);
#    my $hold;
#    my $trans;
#
#    $trans = new ILS::Transaction::Hold;
#
#    # BEGIN TRANSACTION
#    $patron = new ILS::Patron $patron_id;
#    if (!$patron) {
#	$trans->screen_msg("Invalid patron barcode.");
#
#	return $trans;
#    }
#
#    foreach my $i (0 .. scalar @{$patron->{hold_items}}) {
#	$hold = $patron->{hold_items}[$i];
#
#	if ($hold->{item_id} eq $item_id) {
#	    # Found it.  So fix it.
#	    $hold->{expiration_date} = $expiry_date if $expiry_date;
#	    $hold->{pickup_location} = $pickup_location if $pickup_location;
#	    $hold->{hold_type} = $hold_type if $hold_type;
#
#	    $trans->ok(1);
#	    $trans->screen_msg("Hold updated.");
#	    $trans->patron($patron);
#	    $trans->item(new ILS::Item $hold->{item_id});
#	    last;
#	}
#    }
#
#    # The same hold structure is linked into both the patron's
#    # list of hold items and into the queue of outstanding holds
#    # for the item, so we don't need to search the hold queue for
#    # the item, since it's already been updated by the patron code.
#
#    if (!$trans->ok) {
#	$trans->screen_msg("No such outstanding hold.");
#    }
#
#    return $trans;
#}


sub renew {
	my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
		$no_block, $nb_due_date, $third_party, $item_props, $fee_ack) = @_;

	$self->verify_session;

	my $trans = OpenILS::SIP::Transaction::Renew->new( authtoken => $self->{authtoken} );
	$trans->patron($self->find_patron($patron_id));
	$trans->item($self->find_item($item_id));

	if(!$trans->patron) {
		$trans->screen_msg("Invalid patron barcode.");
		$trans->ok(0);
		return $trans;
	}

	if(!$trans->patron->renew_ok) {
		$trans->screen_msg("Renewals not allowed.");
		$trans->ok(0);
		return $trans;
	}

	if(!$trans->item) {
		if( $title_id ) {
			$trans->screen_msg("Item Id renewal not supported.");
		} else {
			$trans->screen_msg("Invalid item barcode.");
		}
		$trans->ok(0);
		return $trans;
	}

	if(!$trans->item->{patron} or 
			$trans->item->{patron} ne $patron_id) {
		$trans->screen_msg("Item not checked out to " . $trans->patron->name);
		$trans->ok(0);
		return $trans;
	}

	# Perform the renewal
	$trans->do_renew();

	$trans->desensitize(0);	# It's already checked out
	$trans->item->{due_date} = $nb_due_date if $no_block eq 'Y';
	$trans->item->{sip_item_properties} = $item_props if $item_props;

	return $trans;
}





#
#sub renew_all {
#    my ($self, $patron_id, $patron_pwd, $fee_ack) = @_;
#    my ($patron, $item_id);
#    my $trans;
#
#    $trans = new ILS::Transaction::RenewAll;
#
#    $trans->patron($patron = new ILS::Patron $patron_id);
#    if (defined $patron) {
#	syslog("LOG_DEBUG", "ILS::renew_all: patron '%s': renew_ok: %s",
#	       $patron->name, $patron->renew_ok);
#    } else {
#	syslog("LOG_DEBUG", "ILS::renew_all: Invalid patron id: '%s'",
#	       $patron_id);
#    }
#
#    if (!defined($patron)) {
#	$trans->screen_msg("Invalid patron barcode.");
#	return $trans;
#    } elsif (!$patron->renew_ok) {
#	$trans->screen_msg("Renewals not allowed.");
#	return $trans;
#    } elsif (defined($patron_pwd) && !$patron->check_password($patron_pwd)) {
#	$trans->screen_msg("Invalid patron password.");
#	return $trans;
#    }
#
#    foreach $item_id (@{$patron->{items}}) {
#	my $item = new ILS::Item $item_id;
#
#	if (!defined($item)) {
#	    syslog("LOG_WARNING",
#		   "renew_all: Invalid item id associated with patron '%s'",
#		   $patron->id);
#	    next;
#	}
#
#	if (@{$item->hold_queue}) {
#	    # Can't renew if there are outstanding holds
#	    push @{$trans->unrenewed}, $item_id;
#	} else {
#	    $item->{due_date} = time + (14*24*60*60); # two weeks hence
#	    push @{$trans->renewed}, $item_id;
#	}
#    }
#
#    $trans->ok(1);
#
#    return $trans;
#}

1;
