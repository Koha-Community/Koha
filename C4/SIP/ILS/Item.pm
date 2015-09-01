#
# ILS::Item.pm
# 
# A Class for hiding the ILS's concept of the item from OpenSIP
#

package C4::SIP::ILS::Item;

use strict;
use warnings;

use Sys::Syslog qw(syslog);
use Carp;

use C4::SIP::ILS::Transaction;

use C4::Debug;
use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Circulation;
use C4::Members;
use C4::Reserves;
use Koha::Database;

our $VERSION = 3.07.00.049;

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

sub priority_sort {
    defined $a->{priority} or return -1;
    defined $b->{priority} or return 1;
    return $a->{priority} <=> $b->{priority};
}

sub new {
	my ($class, $item_id) = @_;
	my $type = ref($class) || $class;
	my $self;
    my $itemnumber = GetItemnumberFromBarcode($item_id);
	my $item = GetBiblioFromItemNumber($itemnumber);    # actually biblio.*, biblioitems.* AND items.*  (overkill)
	if (! $item) {
		syslog("LOG_DEBUG", "new ILS::Item('%s'): not found", $item_id);
		warn "new ILS::Item($item_id) : No item '$item_id'.";
        return;
	}
    $item->{  'itemnumber'   } = $itemnumber;
    $item->{      'id'       } = $item->{barcode};     # to SIP, the barcode IS the id.
    $item->{permanent_location}= $item->{homebranch};
    $item->{'collection_code'} = $item->{ccode};
    $item->{  'call_number'  } = $item->{itemcallnumber};

    my $it = C4::Context->preference('item-level_itypes') ? $item->{itype} : $item->{itemtype};
    my $itemtype = Koha::Database->new()->schema()->resultset('Itemtype')->find( $it );
    $item->{sip_media_type} = $itemtype->sip_media_type() if $itemtype;

	# check if its on issue and if so get the borrower
	my $issue = GetItemIssue($item->{'itemnumber'});
    if ($issue) {
        $item->{due_date} = $issue->{date_due};
    }
	my $borrower = GetMember(borrowernumber=>$issue->{'borrowernumber'});
	$item->{patron} = $borrower->{'cardnumber'};
    my $reserves = GetReservesFromBiblionumber({ biblionumber => $item->{biblionumber} });
    $item->{hold_queue} = [ sort priority_sort @$reserves ];
	$item->{hold_shelf}    = [( grep {   defined $_->{found}  and $_->{found} eq 'W' } @{$item->{hold_queue}} )];
	$item->{pending_queue} = [( grep {(! defined $_->{found}) or  $_->{found} ne 'W' } @{$item->{hold_queue}} )];
	$self = $item;
	bless $self, $type;

    syslog("LOG_DEBUG", "new ILS::Item('%s'): found with title '%s'",
	   $item_id, $self->{title});

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
    call_number         => 0,
    enumchron           => 0,
    location            => 0,
    author              => 0,
    title               => 0,
);

sub next_hold {
    my $self = shift;
    # use Data::Dumper; warn "next_hold() hold_shelf: " . Dumper($self->{hold_shelf}); warn "next_hold() pending_queue: " . $self->{pending_queue};
    foreach (@{$self->hold_shelf}) {    # If this item was taken from the hold shelf, then that reserve still governs
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
    my $self = shift;
    my $borrowernumber = (@_ ? shift: $self->hold_patron_id()) or return;
    my $holder = GetMember(borrowernumber=>$borrowernumber);
    unless ($holder) {
        syslog("LOG_ERR", "While checking hold, GetMember failed for borrowernumber '$borrowernumber'");
        return;
    }
    my $email = $holder->{email} || '';
    my $phone = $holder->{phone} || '';
    my $extra = ($email and $phone) ? " ($email, $phone)" :  # both populated, employ comma
                ($email or  $phone) ? " ($email$phone)"   :  # only 1 populated, we don't care which: no comma
                "" ;                                         # neither populated, empty string
    my $name = $holder->{firstname} ? $holder->{firstname} . ' ' : '';
    $name .= $holder->{surname} . $extra;
    return $name;
}

sub hold_patron_bcode {
    my $self = shift;
    my $borrowernumber = (@_ ? shift: $self->hold_patron_id()) or return;
    my $holder = GetMember(borrowernumber => $borrowernumber);
    if ($holder) {
        if ($holder->{cardnumber}) {
            return $holder->{cardnumber};
        }
    }
    return;
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
    if ($self->{patron}) {
		return '04';    # charged
    } elsif (scalar @{$self->{hold_queue}}) {
		return '08';    # waiting on hold shelf
    } else {
		return '03';    # available
    }                   # FIXME: 01-13 enumerated in spec.
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
sub hold_shelf {
    my $self = shift;
	(defined $self->{hold_shelf}) or return [];
    return $self->{hold_shelf};
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
    return $self->{hold_pickup_date} || 0;
}

# This is a partial check of "availability".  It is not supposed to check everything here.
# An item is available for a patron if it is:
# 1) checked out to the same patron 
#    AND no pending (i.e. non-W) hold queue
# OR
# 2) not checked out
#    AND (not on hold_shelf OR is on hold_shelf for patron)
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
	my $count2 = (defined $self->{hold_shelf}   ) ? scalar @{$self->{hold_shelf}   } : 0;
	$debug and print STDERR "availability check: pending_queue size $count, hold_shelf size $count2\n";
    if (defined($self->{patron_id})) {
	 	($self->{patron_id} eq $for_patron) or return 0;
		return ($count ? 0 : 1);
	} else {	# not checked out
        ($count2) and return $self->barcode_is_borrowernumber($for_patron, $self->{hold_shelf}[0]->{borrowernumber});
	}
	return 0;
}

sub _barcode_to_borrowernumber {
    my $known = shift;
    return unless defined $known;
    my $member = GetMember(cardnumber=>$known) or return;
    return $member->{borrowernumber};
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
sub fill_reserve {
    my $self = shift;
    my $hold = shift or return;
    foreach (qw(biblionumber borrowernumber reservedate)) {
        $hold->{$_} or return;
    }
    return ModReserveFill($hold);
}
1;
__END__

