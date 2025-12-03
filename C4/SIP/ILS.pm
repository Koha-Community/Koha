#
# ILS.pm: Koha ILS interface module
#

package C4::SIP::ILS;

use warnings;
use strict;

use C4::Context;
use C4::SIP::ILS::Item;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction::Checkin;
use C4::SIP::ILS::Transaction::Checkout;
use C4::SIP::ILS::Transaction::FeePayment;
use C4::SIP::ILS::Transaction::Hold;
use C4::SIP::ILS::Transaction::Renew;
use C4::SIP::ILS::Transaction::RenewAll;
use C4::SIP::ILS::Transaction;
use C4::SIP::Sip qw( siplog );

use Koha::Account;
use Koha::Account::Lines;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Items;
use Koha::Libraries;
use Koha::Number::Price;

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
    my ( $class, $institution ) = @_;
    my $type = ref($class) || $class;
    my $self = {};
    siplog( "LOG_DEBUG", "new ILS '%s'", $institution->{id} );
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
    return $self->{institution}->{id};    # consider making this return the whole institution
}

sub institution_id {
    my $self = shift;
    return $self->{institution}->{id};
}

sub supports {
    my ( $self, $op ) = @_;
    return ( exists( $supports{$op} ) && $supports{$op} );
}

sub check_inst_id {
    my ( $self, $id, $whence ) = @_;
    if ( $id ne $self->{institution}->{id} ) {
        siplog(
            "LOG_WARNING", "%s: received institution '%s', expected '%s'", $whence, $id,
            $self->{institution}->{id}
        );

        # Just an FYI check, we don't expect the user to change location from that in SIPconfig.xml
    }
}

sub to_bool {
    my $bool = shift;

    # If it's defined, and matches a true sort of string, or is
    # a non-zero number, then it's true.
    defined($bool) or return;                          # false
    ( $bool =~ /true|y|yes/i ) and return 1;           # true
    return ( $bool =~ /^\d+$/ and $bool != 0 );        # true for non-zero numbers, false otherwise
}

sub checkout_ok {
    my $self = shift;
    return ( exists( $self->{institution}->{policy}->{checkout} )
            && to_bool( $self->{institution}->{policy}->{checkout} ) );
}

sub checkin_ok {
    my $self = shift;
    return ( exists( $self->{institution}->{policy}->{checkin} )
            && to_bool( $self->{institution}->{policy}->{checkin} ) );
}

sub status_update_ok {
    my $self = shift;
    return ( exists( $self->{institution}->{policy}->{status_update} )
            && to_bool( $self->{institution}->{policy}->{status_update} ) );
}

sub offline_ok {
    my $self = shift;
    return ( exists( $self->{institution}->{policy}->{offline} )
            && to_bool( $self->{institution}->{policy}->{offline} ) );
}

#
# Checkout(patron_id, item_id, sc_renew):
#    patron_id & item_id are the identifiers send by the terminal
#    sc_renew is the renewal policy configured on the terminal
# returns a status object that can be queried for the various bits
# of information that the protocol (SIP or NCIP) needs to generate
# the response.

sub checkout {
    my ( $self, $patron_id, $item_id, $sc_renew, $fee_ack, $account, $no_block_due_date ) = @_;
    my ( $patron, $item, $circ );
    my @blocked_item_types;
    if ( defined $account->{blocked_item_types} ) {
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
    } elsif ( !$item ) {
        $circ->screen_msg("Invalid Item");
    } elsif ($no_block_due_date) {

        # A no block due date means we need check this item out to the patron
        # regardless if fines, restrictions or any other things that would
        # typically prevent a patron from checking out.
        # A no block transaction is used for send offline ( store and forward )
        # transaction to Koha. The patron already has possession of the item
        # so it should be checked out to the patron no matter what.
        $circ->do_checkout( $account, $no_block_due_date );

        $item->{borrowernumber} = $patron_id;
        $item->{due_date}       = $circ->{due};
        push( @{ $patron->{items} }, { barcode => $item_id } );
        $circ->desensitize( !$item->magnetic_media );

        siplog(
            "LOG_DEBUG", "ILS::Checkout: patron %s has checked out %s via a no block checkout",
            $patron_id,  join( ', ', map { $_->{barcode} } @{ $patron->{items} } )
        );
    } elsif ( !$patron->charge_ok ) {
        if ( $patron->debarred ) {
            $circ->screen_msg("Patron debarred");
        } elsif ( $patron->expired ) {
            $circ->screen_msg( "Patron expired on "
                    . output_pref( { dt => dt_from_string( $patron->dateexpiry_iso, 'iso' ), dateonly => 1 } ) );
        } elsif ( $patron->fine_blocked ) {
            my $message = "Patron has fines";
            if ( $account->{show_outstanding_amount} ) {
                my $patron_account = Koha::Account->new( { patron_id => $patron->{borrowernumber} } );
                my $balance        = $patron_account->balance;
                if ($balance) {
                    $message .=
                        ( " - You owe " . Koha::Number::Price->new($balance)->format( { with_symbol => 1 } ) . "." );
                }
            }
            $circ->screen_msg($message);
        } else {
            $circ->screen_msg("Patron blocked");
        }
    } elsif ( $item->{borrowernumber}
        && !C4::Context->preference('AllowItemsOnLoanCheckoutSIP')
        && !_ci_cardnumber_cmp( $item->{borrowernumber}, $patron->borrowernumber ) )
    {
        $circ->screen_msg("Item checked out to another patron");
    } elsif ( grep { $_ eq $item->{itemtype} } @blocked_item_types ) {
        $circ->screen_msg("Item type cannot be checked out at this checkout location");
    } else {

        # No block checkouts were handled earlier so there is no need
        # to bass the no block due date here.
        $circ->do_checkout($account);
        if ( $circ->ok ) {

            # If the item is already associated with this patron, then
            # we're renewing it.
            $circ->renew_ok( $item->{borrowernumber}
                    && _ci_cardnumber_cmp( $item->{borrowernumber}, $patron->borrowernumber ) );

            $item->{borrowernumber} = $patron_id;
            $item->{due_date}       = $circ->{due};
            push( @{ $patron->{items} }, { barcode => $item_id } );
            $circ->desensitize( !$item->magnetic_media );

            siplog(
                "LOG_DEBUG", "ILS::Checkout: patron %s has checked out %s",
                $patron_id,  join( ', ', map { $_->{barcode} } @{ $patron->{items} } )
            );
        } else {
            siplog( "LOG_ERR", "ILS::Checkout Issue failed" );
        }
    }

    # END TRANSACTION

    return $circ;
}

sub _ci_cardnumber_cmp {
    my ( $s1, $s2 ) = @_;

    # As the database is case insensitive we need to normalize two strings
    # before comparing them
    return ( uc($s1) eq uc($s2) );
}

# wrapper which allows above to be called for testing

sub test_cardnumber_compare {
    my ( $self, $str1, $str2 ) = @_;
    return _ci_cardnumber_cmp( $str1, $str2 );
}

sub checkin {
    my ( $self, $item_id, $trans_date, $return_date, $current_loc, $item_props, $cancel, $account ) = @_;

    my $checked_in_ok       = $account->{checked_in_ok};
    my $cv_triggers_alert   = $account->{cv_triggers_alert};
    my $holds_block_checkin = $account->{holds_block_checkin};

    my ( $patron, $item, $circ );

    $circ = C4::SIP::ILS::Transaction::Checkin->new();

    # BEGIN TRANSACTION
    $circ->item( $item = C4::SIP::ILS::Item->new($item_id) );

    my $data;
    if ($item) {
        $data = $circ->do_checkin( $current_loc, $return_date, $account );
    } else {
        $circ->alert(1);
        $circ->alert_type(99);
        $circ->ok(0);
        $circ->screen_msg('Invalid Item');
        return $circ;
    }

    if ( !$circ->ok && $circ->alert_type && $circ->alert_type == 98 ) {    # data corruption
        $circ->screen_msg("Checkin failed: data problem");
        siplog( "LOG_WARNING", "Problem with issue_id in issues and old_issues; check the about page" );
    } elsif ( $data->{messages}->{ResFound} && !$circ->ok && $holds_block_checkin ) {
        $circ->screen_msg("Item is on hold, please return to circulation desk");
        siplog( "LOG_DEBUG", "C4::SIP::ILS::Checkin - item on hold" );
    } elsif ( $data->{messages}->{withdrawn} && !$circ->ok && C4::Context->preference("BlockReturnOfWithdrawnItems") ) {
        $circ->screen_msg("Item withdrawn, return not allowed");
        siplog( "LOG_DEBUG", "C4::SIP::ILS::Checkin - item withdrawn" );
    } elsif ( $data->{messages}->{WasLost} && !$circ->ok && C4::Context->preference("BlockReturnOfLostItems") ) {
        $circ->screen_msg("Item lost, return not allowed");
        siplog( "LOG_DEBUG", "C4::SIP::ILS::Checkin - item lost" );
    } elsif ( !$item->{borrowernumber} ) {
        if ($checked_in_ok) {    # Mark checkin ok although book not checked out
            $circ->ok(1);
            siplog( "LOG_DEBUG", "C4::SIP::ILS::Checkin - using checked_in_ok" );
        } else {
            $circ->screen_msg("Item not checked out");
            siplog( "LOG_DEBUG", "C4::SIP::ILS::Checkin - item not checked out" );
        }
    } elsif ( $circ->ok ) {
        $circ->patron( $patron = C4::SIP::ILS::Patron->new( { borrowernumber => $item->{borrowernumber} } ) );
        delete $item->{borrowernumber};
        delete $item->{due_date};
        $patron->{items} = [ grep { $_ ne $item_id } @{ $patron->{items} } ];

        my $message = '';
        if ( $account->{show_checkin_message} ) {
            my $permanent_location;
            if ( C4::Context->preference("UseLocationAsAQInSIP") ) {
                $permanent_location = $item->{'permanent_location'};
            } else {
                $permanent_location = Koha::Libraries->find( $item->{permanent_location} )->branchname;
            }
            $message .= "Item checked-in: $permanent_location - $item->{location}.";
        }

        # Check for overdue fines to display
        if ( $account->{show_outstanding_amount} ) {
            my $kohaitem = Koha::Items->find( { barcode => $item_id } );
            if ($kohaitem) {
                my $charges = Koha::Account::Lines->search(
                    {
                        borrowernumber    => $patron->{borrowernumber},
                        amountoutstanding => { '>' => 0 },
                        debit_type_code   => ['OVERDUE'],
                        itemnumber        => $kohaitem->itemnumber
                    },
                );
                if ($charges) {
                    $message .=
                          "You owe "
                        . Koha::Number::Price->new( $charges->total_outstanding )->format( { with_symbol => 1 } )
                        . " for this item.";
                }
            }
        }
        if ($message) {
            $circ->screen_msg($message);
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
    my ( $self, $patron_id ) = @_;

    # success?, screen_msg, print_line
    return ( 1, 'Thank you!', '' );
}

sub pay_fee {
    my (
        $self, $patron_id, $patron_pwd, $fee_amt, $fee_type, $pay_type, $fee_id, $trans_id, $currency, $is_writeoff,
        $disallow_overpayment, $register_id, $inst_id
    ) = @_;

    my $trans = C4::SIP::ILS::Transaction::FeePayment->new();

    $trans->transaction_id($trans_id);
    my $patron;
    $trans->patron( $patron = C4::SIP::ILS::Patron->new($patron_id) );
    if ( !$patron ) {
        $trans->screen_msg('Invalid patron barcode.');
        return { status => $trans };
    }
    my $trans_result = $trans->pay(
        $patron->{borrowernumber}, $fee_amt, $pay_type, $fee_id, $is_writeoff, $disallow_overpayment,
        $register_id, $inst_id
    );
    my $ok = $trans_result->{ok};
    $trans->ok($ok);

    return {
        status       => $trans,
        pay_response => $trans_result->{pay_response},
        error        => $trans_result->{error},
    };
}

sub add_hold {
    my (
        $self,        $patron_id,       $patron_pwd, $item_id, $title_id,
        $expiry_date, $pickup_location, $hold_type,  $fee_ack
    ) = @_;
    my ( $patron, $item );

    my $trans = C4::SIP::ILS::Transaction::Hold->new();

    $patron = C4::SIP::ILS::Patron->new($patron_id);
    if ( !$patron ) {
        $trans->screen_msg("Invalid patron barcode.");
        return $trans;
    }

    unless ( $item = C4::SIP::ILS::Item->new( $item_id || $title_id ) ) {
        $trans->screen_msg("No such item.");
        return $trans;
    }

    if ( $patron->holds_blocked_by_excessive_fees() ) {
        $trans->screen_msg("Excessive fees blocking placement of hold.");
    }

    if ( $item->fee and $fee_ack ne 'Y' ) {
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

    push( @{ $item->hold_queue },     $hold );
    push( @{ $patron->{hold_items} }, $hold );

    return $trans;
}

sub cancel_hold {
    my ( $self, $patron_id, $patron_pwd, $item_id, $title_id ) = @_;
    my ( $patron, $item, $hold );

    my $trans = C4::SIP::ILS::Transaction::Hold->new();

    $patron = C4::SIP::ILS::Patron->new($patron_id);
    if ( !$patron ) {
        $trans->screen_msg("Invalid patron barcode.");
        return $trans;
    }

    unless ( $item = C4::SIP::ILS::Item->new( $item_id || $title_id ) ) {
        $trans->screen_msg("No such item.");
        return $trans;
    }

    $trans->patron($patron);
    $trans->item($item);
    $trans->drop_hold;
    unless ( $trans->ok ) {
        $trans->screen_msg( "Error with transaction drop_hold: " . $trans->screen_msg );
        return $trans;
    }

    # Remove the hold from the patron's record first
    $patron->drop_hold($item_id);    # different than the transaction drop!

    # Now, remove it from the item record.  If it was on the patron
    # record but not on the item record, we'll treat that as success.
    foreach my $i ( 0 .. scalar @{ $item->hold_queue } ) {
        $hold = $item->hold_queue->[$i];
        if ( $item->barcode_is_borrowernumber( $patron->id, $hold->{borrowernumber} ) ) {

            # found it: delete it.
            splice @{ $item->hold_queue }, $i, 1;
            last;    # ?? should we keep going, in case there are multiples
        }
    }
    if ( C4::Context->preference('HoldCancellationRequestSIP') ) {
        $trans->screen_msg("Hold Cancellation Requested.");
    } else {
        $trans->screen_msg("Hold Cancelled.");
    }

    return $trans;
}

# The patron and item id's can't be altered, but the
# date, location, and type can.

sub alter_hold {
    my (
        $self,        $patron_id,       $patron_pwd, $item_id, $title_id,
        $expiry_date, $pickup_location, $hold_type,  $fee_ack
    ) = @_;
    my ( $patron, $item );
    my $hold;
    my $trans;

    $trans = C4::SIP::ILS::Transaction::Hold->new();

    # BEGIN TRANSACTION
    $patron = C4::SIP::ILS::Patron->new($patron_id);
    unless ($patron) {
        $trans->screen_msg("Invalid patron barcode: '$patron_id'.");
        return $trans;
    }

    foreach my $i ( 0 .. scalar @{ $patron->{hold_items} } ) {
        $hold = $patron->{hold_items}[$i];

        if ( $hold->{item_id} eq $item_id ) {

            # Found it.  So fix it.
            $hold->{expiration_date} = $expiry_date     if $expiry_date;
            $hold->{pickup_location} = $pickup_location if $pickup_location;
            $hold->{hold_type}       = $hold_type       if $hold_type;
            $trans->change_hold();

            # $trans->ok(1);
            $trans->screen_msg("Hold updated.");
            $trans->patron($patron);
            $trans->item( C4::SIP::ILS::Item->new( $hold->{item_id} ) );
            last;
        }
    }

    # The same hold structure is linked into both the patron's
    # list of hold items and into the queue of outstanding holds
    # for the item, so we don't need to search the hold queue for
    # the item, since it's already been updated by the patron code.

    if ( !$trans->ok ) {
        $trans->screen_msg("No such outstanding hold.");
    }

    return $trans;
}

sub renew {
    my (
        $self,       $patron_id,   $patron_pwd, $item_id, $title_id,
        $no_block,   $nb_due_date, $third_party,
        $item_props, $fee_ack
    ) = @_;
    my ( $patron, $item );
    my $trans;

    $trans = C4::SIP::ILS::Transaction::Renew->new();
    $trans->patron( $patron = C4::SIP::ILS::Patron->new($patron_id) );
    if ( !$patron ) {
        $trans->screen_msg("Invalid patron barcode.");
        return $trans;
    } elsif ( !$patron->renew_ok ) {
        $trans->screen_msg("Renewals not allowed.");
        return $trans;
    }

    # Previously: renewing a title, rather than an item (sort of)
    # This is gross, but in a real ILS it would be better

    # if (defined($title_id)) {
    #    foreach my $i (@{$patron->{items}}) {
    #        $item = new ILS::Item $i;
    #        last if ($title_id eq $item->title_id);
    #        $item = undef;
    #    }
    # } else {
    my $j     = 0;
    my $count = scalar @{ $patron->{items} };
    foreach my $i ( @{ $patron->{items} } ) {
        unless ( defined $i->{barcode} ) {    # FIXME: using data instead of objects may violate the abstraction layer
            siplog( "LOG_ERR", "No barcode for item %s of %s: $item_id", $j + 1, $count );
            next;
        }
        siplog( "LOG_DEBUG", "checking item %s of %s: $item_id vs. %s", ++$j, $count, $i->{barcode} );
        if ( $i->{barcode} eq $item_id ) {

            # We have it checked out
            $item = C4::SIP::ILS::Item->new($item_id);
            last;
        }
    }

    # }

    $trans->item($item);
    if ($fee_ack) {
        $trans->fee_ack($fee_ack);
    }

    if ( !defined($item) ) {
        $trans->screen_msg( "Item not checked out to " . $patron->name );    # not checked out to $patron_id
        $trans->ok(0);
    } else {
        $trans->do_renew();
        if ( $trans->renewal_ok() ) {
            $item->{due_date} = $trans->{due};
            $trans->desensitize(0);
        }
    }

    return $trans;
}

sub renew_all {
    my ( $self, $patron_id, $patron_pwd, $fee_ack ) = @_;
    my ( $patron, $item_id );
    my $trans;

    $trans = C4::SIP::ILS::Transaction::RenewAll->new();
    if ($fee_ack) {
        $trans->fee_ack($fee_ack);
    }

    $trans->patron( $patron = C4::SIP::ILS::Patron->new($patron_id) );
    if ( defined $patron ) {
        siplog( "LOG_DEBUG", "ILS::renew_all: patron '%s': renew_ok: %s", $patron->name, $patron->renew_ok );
    } else {
        siplog( "LOG_DEBUG", "ILS::renew_all: Invalid patron id: '%s'", $patron_id );
    }

    if ( !$patron ) {
        $trans->screen_msg("Invalid patron barcode.");
        return $trans;
    } elsif ( !$patron->renew_ok ) {
        $trans->screen_msg("Renewals not allowed.");
        return $trans;
    }

    $trans->do_renew_all;
    $trans->ok(1);
    return $trans;
}

1;

=head1 NAME

ILS - Portability layer to interface between Open-SIP and ILS

=head1 SYNOPSIS

    use ILS;

    # Initialize connection between SIP and the ILS
    my $ils = new ILS (institution => 'Foo Public Library');

    # Basic object access methods
    $inst_name = $self->institution;
    $bool = $self->support($operation);
    $self->check_inst_id($inst_name, "error message");

    # Check to see if certain protocol options are permitted
    $bool = $self->checkout_ok;
    $bool = $self->checkin_ok;
    $bool = $self->status_update_ok;
    $bool = $self->offline_ok;

    $status = $ils->checkout($patron_id, $item_id, $sc_renew);

    $status = $ils->checkin($item_id, $trans_date, $return_date,
                            $current_loc, $item_props, $cancel);

    $status = $ils->end_patron_session($patron_id);

    $status = $ils->pay_fee($patron_id, $patron_pwd, $fee_amt,
                            $fee_type, $pay_type, $fee_id, $trans_id,
                            $currency);

    $status = $ils->add_hold($patron_id, $patron_pwd, $item_id,
                 $title_id, $expiry_date,
                 $pickup_locn, $hold_type, $fee_ack);

    $status = $ils->cancel_hold($patron_id, $patron_pwd,
                                $item_id, $title_id);

    $status = $ils->alter_hold($patron_id, $patron_pwd, $item_id,
                               $title_id, $expiry_date,
                               $pickup_locn, $hold_type,
                               $fee_ack);

    $status = $ils->renew($patron_id, $patron_pwd, $item_id,
                          $title_id, $no_block, $nb_due_date,
                          $third_party, $item_props, $fee_ack);

    $status = $ils->renew_all($patron_id, $patron_pwd, $fee_ack);

=head1 INTRODUCTION

The ILS module defines a basic portability layer between the SIP
server and the rest of the integrated library system.  It is the
responsibility of the ILS vendor to implement the functions
defined by this interface.  This allows the SIP server to be
reasonably portable between ILS systems (of course, we won't know
exactly I<how> portable the interface is until it's been used by
a second ILS.

Because no business logic is embedded in the SIP server code
itself, the SIP protocol handler functions do almost nothing
except decode the network messages and pass the parameters to the
ILS module or one of its submodules, C<ILS::Patron> and
C<ILS::Item>.  The SIP protocol query messages (Patron
Information, or Item Status, for example), are implemented within
the SIP server code by fetching a Patron, or Item, record and
then retrieving the relevant information from that record.  See
L<ILS::Patron> and L<ILS::Item> for the details.

=head1 INITIALIZATION

The first thing the SIP server does, after a terminal has
successfully logged in, is initialize the ILS module by calling

    $ils = new ILS $institution

where C<$institution> is a hash ( institution => 'Foo Public Library' )
describing the institution to which the terminal belongs.
In general, this will be the single institution that the ILS supports,
but it may be that in a consortial setting, the SIP server may support
connecting to different ILSs based on the C<$institution> of the terminal.

=head1 BASIC OBJECT ACCESS AND PROTOCOL SUPPORT

The C<$ils> object supports a small set of simple access methods
and methods that allow the SIP server to determine if certain
protocol operations are permitted to the remote terminals.

=head2 C<$inst_name = $self-E<gt>institution;>

Returns the institution ID as a string, suitable for
incorporating into a SIP response message.

=head2 C<$bool = $self-E<gt>support($operation);>

Reports whether this ILS implementation supports certain
operations that are necessary to report information to the SIP
terminal. The argument C<$operation> is a string from this list:

=over

=item C<'magnetic media'>

Can the ILS properly report whether an item is (or contains)
magnetic media, such as a videotape or a book with a floppy disk?

=item C<'security inhibit'>

Is the ILS capable of directing the terminal to ignore the
security status of an item?

=item C<'offline operation'>

Does the ILS allow self-check units to operate when unconnected
to the ILS?  That is, can a self-check unit check out items to
patrons without checking the status of the items and patrons in
real time?

=back

=head2 C<$bool = $self-E<gt>checkout_ok;>

Are the self service terminals permitted to check items out to
patrons?

=head2 C<$bool = $self-E<gt>checkin_ok;>

Are the self service terminals permitted to check items in?

=head2 C<$bool = $self-E<gt>status_update_ok;>

Are the self service terminals permitted to update patron status
information.  For example, can terminals block patrons?

=head2 C<$bool = $self-E<gt>offline_ok>;

Are the self service terminals permitted to operate off-line.
That is, can they perform their core self service operations when
not in communication with the ILS?

=head1 THE TRANSACTIONS

In general, every protocol transaction that changes the status of
some ILS object (Patron or Item) has a corresponding C<ILS>
method.  Operations like C<Check In>, which are a function of
both a patron and an item are C<ILS> functions, while others,
like C<Patron Status> or C<Item Status>, which only depend on one
type of object, are methods of the corresponding sub-module.

In the stub implementation provided with the SIP system, the
C<$status> objects returned by the various C<ILS> transactions
are objects that are subclasses of a virtual C<ILS::Transaction>
object, but this is not required of the SIP code, as long as the
status objects support the appropriate methods.

=head2 CORE TRANSACTION STATUS METHODS

The C<$status> objects returned by all transactions must support
the following common methods:

=over

=item C<ok>

Returns C<true> if the transaction was successful and C<false> if
not.  Other methods can be used to find out what went wrong.

=item C<item>

Returns an C<ILS::Item> object corresponding to the item with the
barcode C<$item_id>, or C<undef> if the barcode is invalid.

=item C<patron>

Returns a C<ILS::Patron> object corresponding to the patron with
the barcode C<$patron_id>, or C<undef> if the barcode is invalid
(ie, nonexistent, as opposed to "expired" or "delinquent").

=item C<screen_msg>

Optional. Returns a message that is to be displayed on the
terminal's screen.  Some self service terminals read the value of
this string and act based on it.  The configuration of the
terminal, and the ILS implementation of this method will have to
be coordinated.

=item C<print_line>

Optional.  Returns a message that is to be printed on the
terminal's receipt printer.  This message is distinct from the
basic transactional information that the terminal will be
printing anyway (such as, the basic checkout information like the
title and due date).

=back

=head2 C<$status = $ils-E<gt>checkout($patron_id, $item_id, $sc_renew)>

Check out (or possibly renew) item with barcode C<$item_id> to
the patron with barcode C<$patron_id>.  If C<$sc_renew> is true,
then the self-check terminal has been configured to allow
self-renewal of items, and the ILS may take this into account
when deciding how to handle the case where C<$item_id> is already
checked out to C<$patron_id>.

The C<$status> object returned by C<checkout> must support the
following methods:

=over

=item C<renewal_ok>

Is this transaction actually a renewal?  That is, did C<$patron_id>
already have C<$item_id> checked out?

=item C<desensitize>

Should the terminal desensitize the item?  This will be false for
magnetic media, like videocassettes, and for "in library" items
that are checked out to the patron, but not permitted to leave the
building.

=item C<security_inhibit>

Should self checkout unit ignore the security status of this
item?

This method will only be used if

    $ils->supports('security inhibit')

returns C<true>.

=item C<fee_amount>

If there is a fee associated with the use of C<$item_id>, then
this method should return the amount of the fee, otherwise it
should return zero.  See also the C<sip_currency> and
C<sip_fee_type> methods.

=item C<sip_currency>

The ISO currency code for the currency in which the fee
associated with this item is denominated.  For example, 'USD' or
'CAD'.

=item C<sip_fee_type>

A code indicating the type of fee associated with this item.  See
the table in the protocol specification for the complete list of
standard values that this function can return.

=back

=head2 C<$status = $ils-E<gt>checkin($item_id, $trans_date, $return_date, $current_loc, $item_props, $cancel)>

Check in item identified by barcode C<$item_id>.  This
transaction took place at time C<$trans_date> and was effective
C<$return_date> (to allow for backdating of items to when the
branch closed, for example). The self check unit which received
the item is located at C<$current_loc>, and the item has
properties C<$item_props>.  The parameters C<$current_loc> and
C<$item_props> are opaque strings passed from the self service
unit to the ILS untranslated.  The configuration of the terminal,
and the ILS implementation of this method will have to be
coordinated.

The C<$status> object returned by the C<checkin> operation must
support the following methods:

=over

=item C<resensitize>

Does the item need to be resensitized by the self check unit?

=item C<alert>

Should the self check unit generate an audible alert to notify
staff that the item has been returned?

=item C<sort_bin>

Certain self checkin units provide for automated sorting of the
returned items.  This function returns the bin number into which
the received item should be placed.  This function may return the
empty string, or C<undef>, to indicate that no sort bin has been
specified.

=back

=head2 C<($status, $screen_msg, $print_line) = $ils-E<gt>end_patron_session($patron_id)>

This function informs the ILS that the current patron's session
has ended.  This allows the ILS to free up any internal state
that it may be preserving between messages from the self check
unit.  The function returns a boolean C<$status>, where C<true>
indicates success, and two strings: a screen message to display
on the self check unit's console, and a print line to be printed
on the unit's receipt printer.

=head2 C<$status = $ils-E<gt>pay_fee($patron_id, $patron_pwd, $fee_amt, $fee_type, $pay_type, $fee_id, $trans_id, $currency)>

Reports that the self check terminal handled fee payment from
patron C<$patron_id> (who has password C<$patron_pwd>, which is
an optional parameter).  The other parameters are:

=over

=item C<$fee_amt>

The amount of the fee.

=item C<$fee_type>

The type of fee, according a table in the SIP protocol
specification.

=item C<$pay_type>

The payment method.  Defined in the SIP protocol specification.

=item C<$fee_id>

Optional. Identifies which particular fee was paid.  This
identifier would have been sent from the ILS to the Self Check
unit by a previous "Patron Information Response" message.

=item C<$trans_id>

Optional. A transaction identifier set by the payment device.
This should be recorded by the ILS for financial tracking
purposes.

=item C<$currency>

An ISO currency code indicating the currency in which the fee was
paid.

=back

The status object returned by the C<pay_fee> must support the
following methods:

=over

=item C<transaction_id>

Transaction identifier of the transaction.  This parallels the
optional C<$trans_id> sent from the terminal to the ILS.  This
may return an empty string.

=back

=head2 C<$status = $ils-E<gt>add_hold($patron_id, $patron_pwd, $item_id, $title_id, $expiry_date, $pickup_locn, $hold_type, $fee_ack);>

Places a hold for C<$patron_id> (optionally, with password
C<$patron_pwd>) on the item described by either C<$item_id> or
C<$title_id>. The other parameters are:

=over

=item C<$expiry_date>

The date on which the hold should be cancelled.  This date is a
SIP protocol standard format timestamp:

    YYYYMMDDZZZZHHMMSS

where the 'Z' characters indicate spaces.

=item C<$pickup_location>

The location at which the patron wishes to pick up the item when
it's available.  The configuration of the terminal, and the ILS
implementation of this parameter will have to be coordinated.

=item C<$hold_type>

The type of hold being placed: any copy, a specific copy, any
copy from a particular branch or location.  See the SIP protocol
specification for the exact values that this parameter might
take.

=item C<$fee_ack>

Boolean.  If true, the patron has acknowledged that she is willing
to pay the fee associated with placing a hold on this item.  If
C<$fee_ack> is false, then the ILS should refuse to place the
hold.

=back

=head2 C<$status = $ils-E<gt>cancel_hold($patron_id, $patron_pwd, $item_id, $title_id);>

Cancel a hold placed by C<$patron_id> for the item identified by
C<$item_id> or C<$title_id>.  The patron password C<$patron_pwd>
may be C<undef>, if it was not provided by the terminal.

=head2 C<$status = $ils-E<gt>alter_hold($patron_id, $patron_pwd, $item_id, $title_id, $expiry_date, $pickup_locn, $hold_type, $fee_ack);>

The C<$status> object returned by C<$ils-E<gt>add_hold>,
C<$ils-E<gt>cancel_hold>, and C<$ils-E<gt>alter_hold> must all
support the same methods:

=over

=item C<expiration_date>

Returns the expiry date for the placed hold, in seconds since the
epoch.

=item C<queue_position>

Returns the new hold's place in the queue of outstanding holds.

=item C<pickup_location>

Returns the location code for the pickup location.

=back

=head2 C<$status = $ils-E<gt>renew($patron_id, $patron_pwd, $item_id, $title_id, $no_block, $nb_due_date, $third_party, $item_props, $fee_ack);>

Renew the item identified by C<$item_id> or C<$title_id>, as
requested by C<$patron_id> (with password C<$patron_pwd>).  The
item has the properties C<$item_props> associated with it.

If the patron renewed the item while the terminal was
disconnected from the net, then it is a C<$no_block> transaction,
and the due date assigned by the terminal, and reported to the
patron was C<$nb_due_date> (so we have to honor it).

If there is a fee associated with renewing the item, and the
patron has agreed to pay the fee, then C<$fee_ack> will be
C<'Y'>.

If C<$third_party> is C<'Y'> and the book is not checked out to
C<$patron_id>, but to some other person, then this is a
third-party renewal; the item should be renewed for the person to
whom it is checked out, rather than checking it out to
C<$patron_id>, or the renewal should fail.

The C<$status> object returned by C<$ils-E<gt>renew> must support
the following methods:

=over

=item C<renewal_ok>

Boolean.  If C<renewal_ok> is true, then the item was already
checked out to the patron, so it is being renewed.  If
C<renewal_ok> is false, then the patron did not already have the
item checked out.

NOTE: HOW IS THIS USED IN PRACTICE?

=item C<desensitize>, C<security_inhibit>, C<fee_amount>, C<sip_currency>, C<sip_fee_type>, C<transaction_id>

See C<$ils-E<gt>checkout> for these methods.

=back

=head2 C<$status = $ils-E<gt>renew_all($patron_id, $patron_pwd, $fee_ack);>

Renew all items checked out by C<$patron_id> (with password
C<$patron_pwd>).  If the patron has agreed to pay any fees
associated with this transaction, then C<$fee_ack> will be
C<'Y'>.

The C<$status> object must support the following methods:

=over

=item C<renewed>

Returns a list of the C<$item_id>s of the items that were renewed.

=item C<unrenewed>

Returns a list of the C<$item_id>s of the items that were not renewed.

=item C<new>

Missing POD for new.

=item C<find_patron>

Missing POD for find_patron.

=item C<institution>

Missing POD for institution.

=item C<institution_id>

Missing POD for institution_id.

=item C<supports>

Missing POD for supports.

=item C<check_inst_id>

Missing POD for check_inst_id.

=item C<find_item>

Missing POD for find_item.

=item C<test_cardnumber_compare>

Missing POD for test_cardnumber_compare.

=item C<to_bool>

Missing POD for to_bool.

=back
