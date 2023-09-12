#
# ILS.pm: Koha ILS interface module
#

package C4::SIP::ILS;

use warnings;
use strict;
use C4::SIP::Sip qw( siplog );
use Koha::DateUtils qw( dt_from_string output_pref );
use Data::Dumper;

use C4::SIP::ILS::Item;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction;
use C4::SIP::ILS::Transaction::Checkout;
use C4::SIP::ILS::Transaction::Checkin;
use C4::SIP::ILS::Transaction::FeePayment;
use C4::SIP::ILS::Transaction::Hold;
use C4::SIP::ILS::Transaction::Renew;
use C4::SIP::ILS::Transaction::RenewAll;

my %supports = (
    'magnetic media'        => 1,
    'security inhibit'      => 0,
    'offline operation'     => 0,
    "patron status request" => 1,
    "checkout"              => 1,
    "checkin"               => 1,
    "block patron"          => 1,
    "acs status"            => 1,
    "login"                 => 1,
    "patron information"    => 1,
    "end patron session"    => 1,
    "fee paid"              => 1,
    "item information"      => 1,
    "item status update"    => 0,
    "patron enable"         => 1,
    "hold"                  => 1,
    "renew"                 => 1,
    "renew all"             => 1,
);

sub new {
    my ($class, $institution) = @_;
    my $type = ref($class) || $class;
    my $self = {};
    siplog("LOG_DEBUG", "new ILS '%s'", $institution->{id});
    $self->{institution} = $institution;
    return bless $self, $type;
}

sub find_patron {
    my $self = shift;
    return C4::SIP::ILS::Patron->new(@_);
}

sub find_item {
    my $self = shift;
    return C4::SIP::ILS::Item->new(@_);
}

sub institution {
    my $self = shift;
    return $self->{institution}->{id};  # consider making this return the whole institution
}

sub institution_id {
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
        siplog("LOG_WARNING", "%s: received institution '%s', expected '%s'", $whence, $id, $self->{institution}->{id});
        # Just an FYI check, we don't expect the user to change location from that in SIPconfig.xml
    }
}

sub to_bool {
    my $bool = shift;
    # If it's defined, and matches a true sort of string, or is
    # a non-zero number, then it's true.
    defined($bool) or return;                   # false
    ($bool =~ /true|y|yes/i) and return 1;      # true
    return ($bool =~ /^\d+$/ and $bool != 0);   # true for non-zero numbers, false otherwise
}

sub checkout_ok {
    my $self = shift;
    return (exists($self->{institution}->{policy}->{checkout})
	    && to_bool($self->{institution}->{policy}->{checkout}));
}
sub checkin_ok {
    my $self = shift;
    return (exists($self->{institution}->{policy}->{checkin})
	    && to_bool($self->{institution}->{policy}->{checkin}));
}
sub status_update_ok {
    my $self = shift;
    return (exists($self->{institution}->{policy}->{status_update})
	    && to_bool($self->{institution}->{policy}->{status_update}));
}
sub offline_ok {
    my $self = shift;
    return (exists($self->{institution}->{policy}->{offline})
	    && to_bool($self->{institution}->{policy}->{offline}));
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
    my ( $self, $patron_id, $item_id, $sc_renew, $fee_ack, $account, $no_block_due_date ) = @_;
    my ( $patron, $item, $circ );
    my @blocked_item_types;
    if (defined $account->{blocked_item_types}) {
        @blocked_item_types = split /\|/, $account->{blocked_item_types};
    }
    $circ = C4::SIP::ILS::Transaction::Checkout->new();
    # BEGIN TRANSACTION
    $circ->patron( $patron = C4::SIP::ILS::Patron->new($patron_id) );
    $circ->item( $item     = C4::SIP::ILS::Item->new($item_id) );
    if ($fee_ack) {
        $circ->fee_ack($fee_ack);
    }
    if ( !$patron ) {
        $circ->screen_msg("Invalid Patron");
    }
    elsif ( !$patron->charge_ok ) {
        if ($patron->debarred) {
            $circ->screen_msg("Patron debarred");
        } elsif ($patron->expired) {
            $circ->screen_msg("Patron expired on " . output_pref({ dt => dt_from_string( $patron->dateexpiry_iso, 'iso' ), dateonly => 1 }));
        } elsif ($patron->fine_blocked) {
            my $message = "Patron has fines";
            if ($account->{show_outstanding_amount}) {
                my $patron_account = Koha::Account->new( { patron_id => $patron->{borrowernumber} });
                my $balance = $patron_account->balance;
                if ($balance) {
                    $message .= (" - You owe " . Koha::Number::Price->new( $balance )->format({ with_symbol => 1}) . ".");
                }
            }
            $circ->screen_msg($message);
        } else {
            $circ->screen_msg("Patron blocked");
        }
    }
    elsif ( !$item ) {
        $circ->screen_msg("Invalid Item");
    }
    elsif ( $item->{borrowernumber}
        && !_ci_cardnumber_cmp( $item->{borrowernumber}, $patron->borrowernumber ) )
    {
        $circ->screen_msg("Item checked out to another patron");
    }
    elsif (grep { $_ eq $item->{itemtype} } @blocked_item_types) {
        $circ->screen_msg("Item type cannot be checked out at this checkout location");
    }
    else {
        $circ->do_checkout($account, $no_block_due_date);
        if ( $circ->ok ) {

            # If the item is already associated with this patron, then
            # we're renewing it.
            $circ->renew_ok( $item->{borrowernumber}
                  && _ci_cardnumber_cmp( $item->{borrowernumber}, $patron->borrowernumber ) );

            $item->{borrowernumber}   = $patron_id;
            $item->{due_date} = $circ->{due};
            push( @{ $patron->{items} }, { barcode => $item_id } );
            $circ->desensitize( !$item->magnetic_media );

            siplog(
                "LOG_DEBUG", "ILS::Checkout: patron %s has checked out %s",
                $patron_id, join( ', ', map{ $_->{barcode} } @{ $patron->{items} } )
            );
        }
        else {
            siplog( "LOG_ERR", "ILS::Checkout Issue failed" );
        }
    }

    # END TRANSACTION

    return $circ;
}

sub _ci_cardnumber_cmp {
    my ( $s1, $s2) = @_;
    # As the database is case insensitive we need to normalize two strings
    # before comparing them
    return ( uc($s1) eq uc($s2) );
}

# wrapper which allows above to be called for testing

sub test_cardnumber_compare {
    my ($self, $str1, $str2) = @_;
    return _ci_cardnumber_cmp($str1, $str2);
}

sub checkin {
    my ( $self, $item_id, $trans_date, $return_date, $current_loc, $item_props, $cancel, $account ) = @_;

    my $checked_in_ok     = $account->{checked_in_ok};
    my $cv_triggers_alert = $account->{cv_triggers_alert};
    my $holds_block_checkin  = $account->{holds_block_checkin};

    my ( $patron, $item, $circ );

    $circ = C4::SIP::ILS::Transaction::Checkin->new();

    # BEGIN TRANSACTION
    $circ->item( $item = C4::SIP::ILS::Item->new($item_id) );

    my $data;
    if ($item) {
        $data = $circ->do_checkin( $current_loc, $return_date, $account );
    }
    else {
        $circ->alert(1);
        $circ->alert_type(99);
        $circ->ok( 0 );
        $circ->screen_msg('Invalid Item');
        return $circ;
    }

    if ( !$circ->ok && $circ->alert_type && $circ->alert_type == 98 ) { # data corruption
        $circ->screen_msg("Checkin failed: data problem");
        siplog( "LOG_WARNING", "Problem with issue_id in issues and old_issues; check the about page" );
    } elsif ( $data->{messages}->{ResFound} && !$circ->ok && $holds_block_checkin ) {
        $circ->screen_msg("Item is on hold, please return to circulation desk");
        siplog ("LOG_DEBUG", "C4::SIP::ILS::Checkin - item on hold");
    } elsif ( $data->{messages}->{withdrawn} && !$circ->ok && C4::Context->preference("BlockReturnOfWithdrawnItems") ) {
            $circ->screen_msg("Item withdrawn, return not allowed");
            siplog ("LOG_DEBUG", "C4::SIP::ILS::Checkin - item withdrawn");
    } elsif ( $data->{messages}->{WasLost} && !$circ->ok && C4::Context->preference("BlockReturnOfLostItems") ) {
            $circ->screen_msg("Item lost, return not allowed");
            siplog("LOG_DEBUG", "C4::SIP::ILS::Checkin - item lost");
    } elsif ( !$item->{borrowernumber} ) {
        if ( $checked_in_ok ) { # Mark checkin ok although book not checked out
            $circ->ok( 1 );
            siplog("LOG_DEBUG", "C4::SIP::ILS::Checkin - using checked_in_ok");
        } else {
            $circ->screen_msg("Item not checked out");
            siplog("LOG_DEBUG", "C4::SIP::ILS::Checkin - item not checked out");
        }
    } elsif ( $circ->ok ) {
        $circ->patron( $patron = C4::SIP::ILS::Patron->new( { borrowernumber => $item->{borrowernumber} } ) );
        delete $item->{borrowernumber};
        delete $item->{due_date};
        $patron->{items} = [ grep { $_ ne $item_id } @{ $patron->{items} } ];
        # Check for overdue fines to display
        if ($account->{show_outstanding_amount}) {
            my $kohaitem = Koha::Items->find( { barcode => $item_id } );
            if ($kohaitem) {
                my $charges = Koha::Account::Lines->search(
                    {
                        borrowernumber    => $patron->{borrowernumber},
                        amountoutstanding => { '>' => 0 },
                        debit_type_code   => [ 'OVERDUE' ],
                        itemnumber        => $kohaitem->itemnumber
                    },
                );
                if ($charges) {
                    $circ->screen_msg("You owe " . Koha::Number::Price->new( $charges->total_outstanding )->format({ with_symbol => 1}) . " for this item.");
                }
            }
        }
    } else {
        # Checkin failed: Wrongbranch or withdrawn?
        # Bug 10748 with pref BlockReturnOfLostItems adds another case to come
        # here: returning a lost item when the pref is set.
        $circ->screen_msg("Checkin failed");
        siplog( "LOG_WARNING", "Checkin failed: probably for Wrongbranch or withdrawn" );
    }

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
    my ($self, $patron_id, $patron_pwd, $fee_amt, $fee_type, $pay_type, $fee_id, $trans_id, $currency, $is_writeoff, $disallow_overpayment, $register_id) = @_;

    my $trans = C4::SIP::ILS::Transaction::FeePayment->new();

    $trans->transaction_id($trans_id);
    my $patron;
    $trans->patron($patron = C4::SIP::ILS::Patron->new($patron_id));
    if (!$patron) {
        $trans->screen_msg('Invalid patron barcode.');
        return $trans;
    }
    my $trans_result = $trans->pay( $patron->{borrowernumber}, $fee_amt, $pay_type, $fee_id, $is_writeoff, $disallow_overpayment, $register_id );
    my $ok = $trans_result->{ok};
    $trans->ok($ok);

    return {
        status       => $trans,
        pay_response => $trans_result->{pay_response},
        error        => $trans_result->{error},
    };
}

sub add_hold {
    my ($self, $patron_id, $patron_pwd, $item_id, $title_id,
	$expiry_date, $pickup_location, $hold_type, $fee_ack) = @_;
    my ($patron, $item);

	my $trans = C4::SIP::ILS::Transaction::Hold->new();

    $patron = C4::SIP::ILS::Patron->new( $patron_id );
    if ( !$patron ) {
        $trans->screen_msg("Invalid patron barcode.");
        return $trans;
    }

	unless ($item = C4::SIP::ILS::Item->new($item_id || $title_id)) {
		$trans->screen_msg("No such item.");
		return $trans;
	}

    if ( $patron->holds_blocked_by_excessive_fees() ) {
        $trans->screen_msg("Excessive fees blocking placement of hold.");
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

	my $trans = C4::SIP::ILS::Transaction::Hold->new();

    $patron = C4::SIP::ILS::Patron->new( $patron_id );
    if (!$patron) {
		$trans->screen_msg("Invalid patron barcode.");
		return $trans;
    }

    unless ($item = C4::SIP::ILS::Item->new($item_id || $title_id)) {
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
    $patron->drop_hold($item_id); # different than the transaction drop!

    # Now, remove it from the item record.  If it was on the patron
    # record but not on the item record, we'll treat that as success.
    foreach my $i (0 .. scalar @{$item->hold_queue}) {
		$hold = $item->hold_queue->[$i];
		if ($item->barcode_is_borrowernumber($patron->id, $hold->{borrowernumber})) {
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

    $trans = C4::SIP::ILS::Transaction::Hold->new();

    # BEGIN TRANSACTION
    $patron = C4::SIP::ILS::Patron->new( $patron_id );
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
	    $trans->item(C4::SIP::ILS::Item->new( $hold->{item_id}));
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

    $trans = C4::SIP::ILS::Transaction::Renew->new();
    $trans->patron($patron = C4::SIP::ILS::Patron->new( $patron_id ));
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
            unless (defined $i->{barcode}) {    # FIXME: using data instead of objects may violate the abstraction layer
                siplog("LOG_ERR", "No barcode for item %s of %s: $item_id", $j+1, $count);
                next;
            }
            siplog("LOG_DEBUG", "checking item %s of %s: $item_id vs. %s", ++$j, $count, $i->{barcode});
            if ($i->{barcode} eq $item_id) {
				# We have it checked out
				$item = C4::SIP::ILS::Item->new( $item_id );
				last;
			}
		}
    # }

    $trans->item($item);
    if ($fee_ack) {
        $trans->fee_ack($fee_ack);
    }

    if (!defined($item)) {
		$trans->screen_msg("Item not checked out to " . $patron->name);     # not checked out to $patron_id
        $trans->ok(0);
    } else {
        $trans->do_renew();
        if ($trans->renewal_ok()) {
            $item->{due_date} = $trans->{due};
            $trans->desensitize(0);
        }
    }

    return $trans;
}

sub renew_all {
    my ($self, $patron_id, $patron_pwd, $fee_ack) = @_;
    my ($patron, $item_id);
    my $trans;

    $trans = C4::SIP::ILS::Transaction::RenewAll->new();
    if ($fee_ack) {
        $trans->fee_ack($fee_ack);
    }

    $trans->patron($patron = C4::SIP::ILS::Patron->new( $patron_id ));
    if (defined $patron) {
        siplog("LOG_DEBUG", "ILS::renew_all: patron '%s': renew_ok: %s", $patron->name, $patron->renew_ok);
    } else {
        siplog("LOG_DEBUG", "ILS::renew_all: Invalid patron id: '%s'", $patron_id);
    }

    if (!$patron) {
		$trans->screen_msg("Invalid patron barcode.");
		return $trans;
    } elsif (!$patron->renew_ok) {
		$trans->screen_msg("Renewals not allowed.");
		return $trans;
    }

	$trans->do_renew_all;
    $trans->ok(1);
    return $trans;
}

1;
__END__

