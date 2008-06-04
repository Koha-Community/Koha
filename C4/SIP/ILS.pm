#
# ILS.pm: Koha ILS interface module
#

package ILS;

use warnings;
use strict;
use Sys::Syslog qw(syslog);

use ILS::Item;
use ILS::Patron;
use ILS::Transaction;
use ILS::Transaction::Checkout;
use ILS::Transaction::Checkin;
use ILS::Transaction::FeePayment;
use ILS::Transaction::Hold;
use ILS::Transaction::Renew;
use ILS::Transaction::RenewAll;

my $debug = 0;

my %supports = (
		'magnetic media'	=> 1,
		'security inhibit'	=> 0,
		'offline operation'	=> 0,
		"patron status request" => 1,
		"checkout"		=> 1,
		"checkin"		=> 1,
		"block patron"		=> 1,
		"acs status"		=> 1,
		"login"			=> 1,
		"patron information"	=> 1,
		"end patron session"	=> 1,
		"fee paid"		=> 0,
		"item information"	=> 1,
		"item status update"	=> 0,
		"patron enable"		=> 1,
		"hold"			=> 1,
		"renew"			=> 1,
		"renew all"		=> 1,
	       );

sub new {
    my ($class, $institution) = @_;
    my $type = ref($class) || $class;
    my $self = {};
	use Data::Dumper;
	$debug and warn "new ILS: INSTITUTION: " . Dumper($institution);
    syslog("LOG_DEBUG", "new ILS '%s'", $institution->{id});
    $self->{institution} = $institution;
    return bless $self, $type;
}

sub find_patron {
    my $self = shift;
 	$debug and warn "ILS: finding patron";
    return ILS::Patron->new(@_);
}

sub find_item {
    my $self = shift;
	$debug and warn "ILS: finding item";
    return ILS::Item->new(@_);
}

sub institution {
    my $self = shift;
    return $self->{institution}->{id};
}

sub supports {
    my ($self, $op) = @_;
    return (exists($supports{$op}) && $supports{$op});
}

sub check_inst_id {
    my ($self, $id, $whence) = @_;
    if ($id ne $self->{institution}->{id}) {
	syslog("LOG_WARNING", "%s: received institution '%s', expected '%s'",
	       $whence, $id, $self->{institution}->{id});
    }
}

sub to_bool {
    my $bool = shift;
    # If it's defined, and matches a true sort of string, or is
    # a non-zero number, then it's true.
	#
	# FIXME: this test is faulty
	# 	We're running under warnings and strict.
	#	But if we don't match regexp, then we go ahead and numerical compare?
	# 	That means we'd generate a warning on 'FALSE' or ''.
    return defined($bool) && (($bool =~ /true|y|yes/i) || $bool != 0);
}

sub checkout_ok {
    my $self = shift;
    return (exists($self->{policy}->{checkout})
	    && to_bool($self->{policy}->{checkout}));
}
sub checkin_ok {
    my $self = shift;
    return (exists($self->{policy}->{checkin})
	    && to_bool($self->{policy}->{checkin}));
}
sub status_update_ok {
    my $self = shift;
    return (exists($self->{policy}->{status_update})
	    && to_bool($self->{policy}->{status_update}));
}
sub offline_ok {
    my $self = shift;
    return (exists($self->{policy}->{offline})
	    && to_bool($self->{policy}->{offline}));
}

#
# Checkout(patron_id, item_id, sc_renew):
#    patron_id & item_id are the identifiers send by the terminal
#    sc_renew is the renewal policy configured on the terminal
# returns a status opject that can be queried for the various bits
# of information that the protocol (SIP or NCIP) needs to generate
# the response.
#
sub checkout {
    my ($self, $patron_id, $item_id, $sc_renew) = @_;
    my ($patron, $item, $circ);

    $circ = new ILS::Transaction::Checkout;
    # BEGIN TRANSACTION
    $circ->patron($patron = new ILS::Patron $patron_id);
    $circ->item($item = new ILS::Item $item_id);

    if (!$patron) {
		$circ->screen_msg("Invalid Patron");
    } elsif (!$patron->charge_ok) {
		$circ->screen_msg("Patron Blocked");
    } elsif (!$item) {
		$circ->screen_msg("Invalid Item");
    } elsif ($item->hold_queue && @{$item->hold_queue} && ($patron_id ne $item->hold_queue->[0])) {
		$circ->screen_msg("Item on Hold for Another User");
    } elsif ($item->{patron} && ($item->{patron} ne $patron_id)) {
	# I can't deal with this right now
		$circ->screen_msg("Item checked out to another patron");
    } else {
		$circ->do_checkout();
		if ($circ->ok){
			warn "circ is ok";
			# If the item is already associated with this patron, then
			# we're renewing it.
			$circ->renew_ok($item->{patron} && ($item->{patron} eq $patron_id));
		
			$item->{patron} = $patron_id;
			$item->{due_date} = $circ->{due};
			push(@{$patron->{items}}, $item_id);
			$circ->desensitize(!$item->magnetic);

			syslog("LOG_DEBUG", "ILS::Checkout: patron %s has checked out %s",
				$patron_id, join(', ', @{$patron->{items}}));
		}
		else {
			syslog("LOG_DEBUG", "ILS::Checkout Issue failed");
		}
    }
    # END TRANSACTION

    return $circ;
}

sub checkin {
    my ($self, $item_id, $trans_date, $return_date,
	$current_loc, $item_props, $cancel) = @_;
    my ($patron, $item, $circ);

    $circ = new ILS::Transaction::Checkin;
    # BEGIN TRANSACTION
    $circ->item($item = new ILS::Item $item_id);
    
    $circ->do_checkin();    
	# It's ok to check it in if it exists, and if it was checked out
	$circ->ok($item && $item->{patron});

    if ($circ->ok) {
		$circ->patron($patron = new ILS::Patron $item->{patron});
		delete $item->{patron};
		delete $item->{due_date};
		$patron->{items} = [ grep {$_ ne $item_id} @{$patron->{items}} ];
    }
    # END TRANSACTION

    return $circ;
}

# If the ILS caches patron information, this lets it free
# it up
sub end_patron_session {
    my ($self, $patron_id) = @_;

    # success?, screen_msg, print_line
    return (1, 'Thank you !', '');
}

sub pay_fee {
    my ($self, $patron_id, $patron_pwd, $fee_amt, $fee_type,
	$pay_type, $fee_id, $trans_id, $currency) = @_;
    my $trans;
    my $patron;

#    $trans = new ILS::Transaction::FeePayment;

    $patron = new ILS::Patron $patron_id;

    $trans->transaction_id($trans_id);
    $trans->patron($patron);
    $trans->ok(1);

    return $trans;
}

sub add_hold {
    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
	$expiry_date, $pickup_location, $hold_type, $fee_ack) = @_;
    my ($patron, $item);

	my $trans = new ILS::Transaction::Hold;

    $patron = new ILS::Patron $patron_id;
    if (!$patron
	|| (defined($patron_pwd) && !$patron->check_password($patron_pwd))) {
		$trans->screen_msg("Invalid Patron.");
		return $trans;
    }

	unless ($item = new ILS::Item ($item_id || $title_id)) {
		$trans->screen_msg("No such item.");
		return $trans;
	}

   if ($item->fee and $fee_ack ne 'Y') {
		$trans->screen_msg = "Fee required to place hold.";
		return $trans;
    }

    my $hold = {
	item_id         => $item->id,
	patron_id       => $patron->id,
	expiration_date => $expiry_date,
	pickup_location => $pickup_location,
	hold_type       => $hold_type,
    };

    $trans->ok(1);
    $trans->patron($patron);
    $trans->item($item);
    $trans->pickup_location($pickup_location);
	$trans->do_hold;

    push(@{$item->hold_queue},     $hold);
    push(@{$patron->{hold_items}}, $hold);

    return $trans;
}

sub cancel_hold {
    my ($self, $patron_id, $patron_pwd, $item_id, $title_id) = @_;
    my ($patron, $item, $hold);

	my $trans = new ILS::Transaction::Hold;

    $patron = new ILS::Patron $patron_id;
    if (!$patron) {
		$trans->screen_msg("Invalid patron barcode.");
		return $trans;
    } elsif (defined($patron_pwd) && !$patron->check_password($patron_pwd)) {
		$trans->screen_msg('Invalid patron password.');
		return $trans;
    }

    unless ($item = new ILS::Item ($item_id || $title_id)) {
		$trans->screen_msg("No such item.");
		return $trans;
    }

    $trans->patron($patron);
    $trans->item($item);
	$trans->drop_hold;
	unless ($trans->ok) {
		$trans->screen_msg("Error with transaction drop_hold: " . $trans->screen_msg);
		return $trans;
	}
    # Remove the hold from the patron's record first
    $trans->ok($patron->drop_hold($item_id));	# different than the transaction drop!

    unless ($trans->ok) {
		# We didn't find it on the patron record
		$trans->screen_msg("No such hold on patron record.");
		return $trans;
    }

    # Now, remove it from the item record.  If it was on the patron
    # record but not on the item record, we'll treat that as success.
    foreach my $i (0 .. scalar @{$item->hold_queue}) {
		$hold = $item->hold_queue->[$i];
		if ($hold->{patron_id} eq $patron->id) {
		    # found it: delete it.
		    splice @{$item->hold_queue}, $i, 1;
		    last;		# ?? should we keep going, in case there are multiples
		}
    }

    $trans->screen_msg("Hold Cancelled.");

    return $trans;
}


# The patron and item id's can't be altered, but the
# date, location, and type can.
sub alter_hold {
    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
	$expiry_date, $pickup_location, $hold_type, $fee_ack) = @_;
    my ($patron, $item);
    my $hold;
    my $trans;

    $trans = new ILS::Transaction::Hold;

    # BEGIN TRANSACTION
    $patron = new ILS::Patron $patron_id;
    unless ($patron) {
		$trans->screen_msg("Invalid patron barcode: '$patron_id'.");
		return $trans;
    }

    foreach my $i (0 .. scalar @{$patron->{hold_items}}) {
		$hold = $patron->{hold_items}[$i];

	if ($hold->{item_id} eq $item_id) {
	    # Found it.  So fix it.
	    $hold->{expiration_date} = $expiry_date     if $expiry_date;
	    $hold->{pickup_location} = $pickup_location if $pickup_location;
	    $hold->{hold_type}       = $hold_type       if $hold_type;
		$trans->change_hold();
	    # $trans->ok(1);
	    $trans->screen_msg("Hold updated.");
	    $trans->patron($patron);
	    $trans->item(new ILS::Item $hold->{item_id});
	    last;
	}
    }

    # The same hold structure is linked into both the patron's
    # list of hold items and into the queue of outstanding holds
    # for the item, so we don't need to search the hold queue for
    # the item, since it's already been updated by the patron code.

    if (!$trans->ok) {
		$trans->screen_msg("No such outstanding hold.");
    }

    return $trans;
}

sub renew {
    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
	$no_block, $nb_due_date, $third_party,
	$item_props, $fee_ack) = @_;
    my ($patron, $item);
    my $trans;

    $trans = new ILS::Transaction::Renew;
    $trans->patron($patron = new ILS::Patron $patron_id);

    if (!$patron) {
		$trans->screen_msg("Invalid patron barcode.");
		return $trans;
    } elsif (!$patron->renew_ok) {
		$trans->screen_msg("Renewals not allowed.");
		return $trans;
    }

	# Previously: renewing a title, rather than an item (sort of)
	# This is gross, but in a real ILS it would be better

    # if (defined($title_id)) {
	#	foreach my $i (@{$patron->{items}}) {
	#		$item = new ILS::Item $i;
	#		last if ($title_id eq $item->title_id);
	#		$item = undef;
	#	}
    # } else {
		my $j = 0;
		my $count = scalar @{$patron->{items}};
		foreach my $i (@{$patron->{items}}) {
			syslog("LOG_DEBUG", "checking item %s of %s: $item_id vs. %s", ++$j, $count, $i);
			if ($i eq $item_id) {
				# We have it checked out
				$item = new ILS::Item $item_id;
				last;
			}
		}
    # }

    $trans->item($item);

    if (!defined($item)) {
	# It's not checked out to $patron_id
		$trans->screen_msg("Item not checked out to " . $patron->name);
    } elsif (!$item->available($patron_id)) {
		$trans->screen_msg("Item unavailable due to outstanding holds");
    } else {
		$trans->renewal_ok(1);
		$trans->desensitize(0);	# It's already checked out
		$trans->do_renew();
		syslog("LOG_DEBUG", "done renew (%s): %s renews %s", $trans->renewal_ok(1),$patron_id,$item_id);

#		if ($no_block eq 'Y') {
#			$item->{due_date} = $nb_due_date;
#		} else {
#			$item->{due_date} = time + (14*24*60*60); # two weeks
#		}
#		if ($item_props) {
#			$item->{sip_item_properties} = $item_props;
#		}
#		$trans->ok(1);
#		return $trans;
    }

    return $trans;
}

sub renew_all {
    my ($self, $patron_id, $patron_pwd, $fee_ack) = @_;
    my ($patron, $item_id);
    my $trans;

    $trans = new ILS::Transaction::RenewAll;

    $trans->patron($patron = new ILS::Patron $patron_id);
    if (defined $patron) {
	syslog("LOG_DEBUG", "ILS::renew_all: patron '%s': renew_ok: %s",
	       $patron->name, $patron->renew_ok);
    } else {
	syslog("LOG_DEBUG", "ILS::renew_all: Invalid patron id: '%s'",
	       $patron_id);
    }

    if (!defined($patron)) {
		$trans->screen_msg("Invalid patron barcode.");
		return $trans;
    } elsif (!$patron->renew_ok) {
		$trans->screen_msg("Renewals not allowed.");
		return $trans;
    } elsif (defined($patron_pwd) && !$patron->check_password($patron_pwd)) {
		$trans->screen_msg("Invalid patron password.");
		return $trans;
    }

	$trans->do_renew_all;
    $trans->ok(1);
    return $trans;
}

1;
__END__

