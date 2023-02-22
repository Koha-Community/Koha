#
# ILS::Item.pm
# 
# A Class for hiding the ILS's concept of the item from OpenSIP
#

package C4::SIP::ILS::Item;

use strict;
use warnings;

use C4::SIP::Sip qw(siplog);
use Carp;

use C4::SIP::ILS::Transaction;
use C4::SIP::Sip qw(add_field maybe_add);

use C4::Biblio;
use C4::Circulation qw( barcodedecode );
use C4::Context;
use C4::Items;
use C4::Members;
use Koha::Biblios;
use Koha::Checkouts::ReturnClaims;
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;
use Koha::Items;
use Koha::Patrons;
use Koha::TemplateUtils qw( process_tt );

=encoding UTF-8

=head1 EXAMPLE

 our %item_db = (
    '1565921879' => {
        title => "Perl 5 desktop reference",
        id => '1565921879',
        sip_media_type => '001',
        magnetic_media => 0,
        hold_queue => [],
    },
    '0440242746' => {
        title => "The deep blue alibi",
        id => '0440242746',
        sip_media_type => '001',
        magnetic_media => 0,
        hold_queue => [
            {
            itemnumber => '823',
            priority => '1',
            reservenotes => undef,
            reservedate => '2008-10-09',
            found => undef,
            rtimestamp => '2008-10-09 11:15:06',
            biblionumber => '406',
            borrowernumber => '756',
            branchcode => 'CPL'
            }
        ],
    },
    '660' => {
        title => "Harry Potter y el cáliz de fuego",
        id => '660',
        sip_media_type => '001',
        magnetic_media => 0,
        hold_queue => [],
    },
);

=cut

sub new {
    my ($class, $item_id) = @_;
    my $type = ref($class) || $class;
    my $item = Koha::Items->find( { barcode => barcodedecode( $item_id ) } );
    unless ( $item ) {
        siplog("LOG_DEBUG", "new ILS::Item('%s'): not found", $item_id);
        warn "new ILS::Item($item_id) : No item '$item_id'.";
        return;
    }
    my $self = $item->unblessed;
    $self->{_object}            = $item;
    $self->{id}                 = $item->barcode; # to SIP, the barcode IS the id.
    if (C4::Context->preference('UseLocationAsAQInSIP')) {
        $self->{permanent_location} = $item->permanent_location;
    } else {
        $self->{permanent_location} = $item->homebranch;
    }
    $self->{collection_code}    = $item->ccode;
    $self->{call_number}        = $item->itemcallnumber;
    $self->{'shelving_location'}           = $item->location;
    $self->{'permanent_shelving_location'} = $item->permanent_location;

    $self->{object} = $item;

    my $it = $item->effective_itemtype;
    $self->{itemtype} = $it;
    my $itemtype = Koha::Database->new()->schema()->resultset('Itemtype')->find( $it );
    $self->{sip_media_type} = $itemtype->sip_media_type() if $itemtype;

    # check if its on issue and if so get the borrower
    my $issue = Koha::Checkouts->find( { itemnumber => $item->itemnumber } );
    if ($issue) {
        $self->{due_date} = dt_from_string( $issue->date_due, 'sql' )->truncate( to => 'minute' );
        my $patron = Koha::Patrons->find( $issue->borrowernumber );
        $self->{borrowernumber} = $patron->borrowernumber;
    }
    my $biblio = Koha::Biblios->find( $self->{biblionumber} );
    my $holds = $biblio->current_holds->unblessed;
    $self->{hold_queue} = $holds;
    $self->{hold_attached} = [( grep { defined $_->{found}  and ( $_->{found} eq 'W' or $_->{found} eq 'P' or $_->{found} eq 'T' ) } @{$self->{hold_queue}} )];
    $self->{pending_queue} = [( grep {(! defined $_->{found}) or ( $_->{found} ne 'W' and $_->{found} ne 'P' and $_->{found} ne 'T' ) } @{$self->{hold_queue}} )];
    $self->{title} = $biblio->title;
    $self->{author} = $biblio->author;
    bless $self, $type;

    siplog( "LOG_DEBUG", "new ILS::Item('%s'): found with title '%s'",
        $item_id, $self->{title} // '' );

    return $self;
}

# 0 means read-only
# 1 means read/write

my %fields = (
    id                  => 0,
    sip_media_type      => 0,
    sip_item_properties => 0,
    magnetic_media      => 0,
    permanent_location  => 0,
    current_location    => 0,
    print_line          => 1,
    screen_msg          => 1,
    itemnumber          => 0,
    biblionumber        => 0,
    barcode             => 0,
    onloan              => 0,
    collection_code     => 0,
    shelving_location   => 0,
    permanent_shelving_location   => 0,
    call_number         => 0,
    enumchron           => 0,
    location            => 0,
    author              => 0,
    title               => 0,
    itemtype            => 0,
);

sub next_hold {
    my $self = shift;
    # use Data::Dumper; warn "next_hold() hold_attached: " . Dumper($self->{hold_attached}); warn "next_hold() pending_queue: " . $self->{pending_queue};
    foreach (@{$self->hold_attached}) {    # If this item was taken from the hold shelf, then that reserve still governs
        next unless ($_->{itemnumber} and $_->{itemnumber} == $self->{itemnumber});
        return $_;
    }
    if (scalar @{$self->{pending_queue}}) {    # Otherwise, if there is at least one hold, the first (best priority) gets it
        return  $self->{pending_queue}->[0];
    }
    return;
}

# hold_patron_id is NOT the barcode.  It's the borrowernumber.
# If a return triggers capture for a hold the borrowernumber is passed
# and saved so that other hold info can be retrieved
sub hold_patron_id {
    my $self = shift;
    my $id   = shift;
    if ($id) {
        $self->{hold}->{borrowernumber} = $id;
    }
    if ($self->{hold} ) {
        return $self->{hold}->{borrowernumber};
    }
    return;

}
sub hold_patron_name {
    my ( $self, $template ) = @_;
    my $borrowernumber = $self->hold_patron_id() or return q{};

    if ($template) {
        my $patron = Koha::Patrons->find($borrowernumber);
        return process_tt( $template, { patron => $patron } );
    }

    my $holder = Koha::Patrons->find( $borrowernumber );
    unless ($holder) {
        siplog("LOG_ERR", "While checking hold, failed to retrieve the patron with borrowernumber '$borrowernumber'");
        return q{};
    }
    my $email = $holder->email || '';
    my $phone = $holder->phone || '';
    my $extra = ($email and $phone) ? " ($email, $phone)" :  # both populated, employ comma
                ($email or  $phone) ? " ($email$phone)"   :  # only 1 populated, we don't care which: no comma
                "" ;                                         # neither populated, empty string
    my $name = $holder->firstname ? $holder->firstname . ' ' : '';
    $name .= $holder->surname . $extra;
    return $name;
}

sub hold_patron_bcode {
    my $self = shift;
    my $borrowernumber = (@_ ? shift: $self->hold_patron_id()) or return q{};
    my $holder = Koha::Patrons->find( $borrowernumber );
    if ($holder and $holder->cardnumber ) {
        return $holder->cardnumber;
    }
    return q();
}

sub destination_loc {
    my $self = shift;
    my $set_loc = shift;
    if ($set_loc) {
        $self->{dest_loc} = $set_loc;
    }
    if ($self->{dest_loc} ) {
        return $self->{dest_loc};
    }
    return q{};
}

our $AUTOLOAD;

sub DESTROY { } # keeps AUTOLOAD from catching inherent DESTROY calls

sub AUTOLOAD {
    my $self = shift;
    my $class = ref($self) or croak "$self is not an object";
    my $name = $AUTOLOAD;

    $name =~ s/.*://;

    unless (exists $fields{$name}) {
		croak "Cannot access '$name' field of class '$class'";
    }

	if (@_) {
        $fields{$name} or croak "Field '$name' of class '$class' is READ ONLY.";
		return $self->{$name} = shift;
	} else {
		return $self->{$name};
	}
}

sub status_update {     # FIXME: this looks unimplemented
    my ($self, $props) = @_;
    my $status = C4::SIP::ILS::Transaction->new();
    $self->{sip_item_properties} = $props;
    $status->{ok} = 1;
    return $status;
}

sub title_id {
    my $self = shift;
    return $self->{title};
}

sub sip_circulation_status {
    my $self = shift;
    if ( $self->{_object}->get_transfer ) {
        return '10'; # in transit between libraries
    }
    elsif ( Koha::Checkouts::ReturnClaims->search({ itemnumber => $self->{_object}->id, resolution => undef })->count ) {
        return '11';    # claimed returned
    }
    elsif ( $self->{itemlost} ) {
        return '12';    # lost
    }
    elsif ( $self->{borrowernumber} ) {
        return '04';    # charged
    }
    elsif ( grep { $_->{itemnumber} == $self->{itemnumber}  } @{ $self->{hold_attached} } ) {
        return '08';    # waiting on hold shelf
    }
    elsif ( $self->{location} and $self->{location} eq 'CART' ) {
        return '09';    # waiting to be re-shelved
    }
    elsif ( $self->{damaged} ) {
        return '01';    # damaged
    }
    elsif ( $self->{notforloan} < 0 ) {
        return '02';    # on order
    }
    else {
        return '03';    # available
    }    # FIXME: 01-13 enumerated in spec.
}

sub sip_security_marker {
    my $self = shift;
    return '02';	# FIXME? 00-other; 01-None; 02-Tattle-Tape Security Strip (3M); 03-Whisper Tape (3M)
}
sub sip_fee_type {
    my $self = shift;
    return '01';    # FIXME? 01-09 enumerated in spec.  We just use O1-other/unknown.
}

sub fee {
    my $self = shift;
    return $self->{fee} || 0;
}
sub fee_currency {
    my $self = shift;
    return $self->{currency} || 'USD';
}
sub owner {
    my $self = shift;
    return $self->{homebranch};
}
sub hold_queue {
    my $self = shift;
	(defined $self->{hold_queue}) or return [];
    return $self->{hold_queue};
}
sub pending_queue {
    my $self = shift;
	(defined $self->{pending_queue}) or return [];
    return $self->{pending_queue};
}
sub hold_attached {
    my $self = shift;
    (defined $self->{hold_attached}) or return [];
    return $self->{hold_attached};
}

sub hold_queue_position {
	my ($self, $patron_id) = @_;
	($self->{hold_queue}) or return 0;
	my $i = 0;
	foreach (@{$self->{hold_queue}}) {
		$i++;
		$_->{patron_id} or next;
		if ($self->barcode_is_borrowernumber($patron_id, $_->{borrowernumber})) {
			return $i;  # maybe should return $_->{priority}
		}
	}
    return 0;
}

sub due_date {
    my $self = shift;
    return $self->{due_date} || 0;
}
sub recall_date {
    my $self = shift;
    return $self->{recall_date} || 0;
}
sub hold_pickup_date {
    my $self = shift;

    my $hold = Koha::Holds->find({ itemnumber => $self->{itemnumber}, found => 'W' });
    if ( $hold ) {
        return $hold->expirationdate || 0;
    }

    return 0;
}

# This is a partial check of "availability".  It is not supposed to check everything here.
# An item is available for a patron if it is:
# 1) checked out to the same patron 
#    AND no pending (i.e. non-W) hold queue
# OR
# 2) not checked out
#    AND (not on hold_attached OR is on hold_attached for patron)
#
# What this means is we are consciously allowing the patron to checkout (but not renew) an item that DOES
# have non-W holds on it, but has not been "picked" from the stacks.  That is to say, the
# patron has retrieved the item before the librarian.
#
# We don't check if the patron is at the front of the pending queue in the first case, because
# they should not be able to place a hold on an item they already have.

sub available {
	my ($self, $for_patron) = @_;
	my $count  = (defined $self->{pending_queue}) ? scalar @{$self->{pending_queue}} : 0;
    my $count2 = (defined $self->{hold_attached}   ) ? scalar @{$self->{hold_attached}   } : 0;
    if (defined($self->{borrowernumber})) {
        ($self->{borrowernumber} eq $for_patron) or return 0;
		return ($count ? 0 : 1);
	} else {	# not checked out
        ($count2) and return $self->barcode_is_borrowernumber($for_patron, $self->{hold_attached}[0]->{borrowernumber});
	}
	return 0;
}

sub _barcode_to_borrowernumber {
    my $known = shift;
    return unless defined $known;
    my $patron = Koha::Patrons->find( { cardnumber => $known } ) or return;
    return $patron->borrowernumber
}
sub barcode_is_borrowernumber {    # because hold_queue only has borrowernumber...
    my $self = shift;
    my $barcode = shift;
    my $number  = shift or return;    # can't be zero
    return unless defined $barcode; # might be 0 or 000 or 000000
    my $converted = _barcode_to_borrowernumber($barcode);
    return unless $converted;
    return ($number == $converted);
}

=head2 build_additional_item_fields_string

This method builds the part of the sip message for additional item fields
to send in the item related message responses

=cut

sub build_additional_item_fields_string {
    my ( $self, $server ) = @_;

    my $string = q{};

    if ( $server->{account}->{item_field} ) {
        my @fields_to_send =
          ref $server->{account}->{item_field} eq "ARRAY"
          ? @{ $server->{account}->{item_field} }
          : ( $server->{account}->{item_field} );

        foreach my $f ( @fields_to_send ) {
            my $code = $f->{code};
            my $value = $self->{object}->$code;
            $string .= add_field( $f->{field}, $value );
        }
    }

    if ( $server->{account}->{custom_item_field} ) {
        my @custom_fields =
            ref $server->{account}->{custom_item_field} eq "ARRAY"
            ? @{ $server->{account}->{custom_item_field} }
            : $server->{account}->{custom_item_field};

        foreach my $custom_field ( @custom_fields ) {
            my $field = $custom_field->{field};
            return q{} unless defined $field;
            my $template = $custom_field->{template};
            my $formatted = $self->format( $template );
            my $substring = maybe_add( $field, $formatted, $server );
            $string .= $substring;
        }
    }

    return $string;
}

=head2 build_custom_field_string

This method builds the part of the sip message for custom item fields as defined in the sip config

=cut

sub build_custom_field_string {
    my ( $self, $server ) = @_;

    my $string = q{};


    return $string;
}

=head2 format

This method uses a template to build a string from a Koha::Item object
If errors are encountered in processing template we log them and return nothing

=cut

sub format {
    my ( $self, $template ) = @_;

    if ($template) {
        my $item = $self->{_object};
        return process_tt( $template, { item => $item } );
    }
}

1;
__END__

