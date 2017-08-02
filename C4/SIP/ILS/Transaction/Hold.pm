#
# status of a Hold transaction

package C4::SIP::ILS::Transaction::Hold;

use Modern::Perl;

use C4::SIP::ILS::Transaction;

use C4::Reserves;	# AddReserve
use Koha::Holds;
use Koha::Patrons;
use parent qw(C4::SIP::ILS::Transaction);

use Koha::Items;

my %fields = (
	expiration_date => 0,
	pickup_location => undef,
	constraint_type => undef,
);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
    foreach my $element (keys %fields) {
		$self->{_permitted}->{$element} = $fields{$element};
	}
	@{$self}{keys %fields} = values %fields;
	return bless $self, $class;
}

sub queue_position {
    my $self = shift;
    return $self->item->hold_queue_position($self->patron->id);
}

sub do_hold {
    my $self = shift;
    unless ( $self->{patron} ) {
        $self->screen_msg('do_hold called with undefined patron');
        $self->ok(0);
        return $self;
    }
    my $patron = Koha::Patrons->find( { cardnumber => $self->{patron}->id } );
    unless ($patron) {
        $self->screen_msg( 'No borrower matches cardnumber "' . $self->{patron}->id . '".' );
        $self->ok(0);
        return $self;
    }
    my $item = Koha::Items->find({ barcode => $self->{item}->id });
    unless ($item) {
        $self->screen_msg( 'No biblio record matches barcode "' . $self->{item}->id . '".' );
        $self->ok(0);
        return $self;
    }
    my $branch = ( $self->pickup_location || $self->{patron}->branchcode );
    unless ($branch) {
        $self->screen_msg('No branch specified (or found w/ patron).');
        $self->ok(0);
        return $self;
    }
    AddReserve( $branch, $patron->borrowernumber, $item->biblionumber );

    # unfortunately no meaningful return value
    $self->ok(1);
    return $self;
}

sub drop_hold {
	my $self = shift;
	unless ($self->{patron}) {
		$self->screen_msg('drop_hold called with undefined patron');
		$self->ok(0);
		return $self;
	}
    my $patron = Koha::Patrons->find( { cardnumber => $self->{patron}->id } );
    unless ($patron) {
		$self->screen_msg('No borrower matches cardnumber "' . $self->{patron}->id . '".');
		$self->ok(0);
		return $self;
	}
    my $item = Koha::Items->find({ barcode => $self->{item}->id });

    my $holds = Koha::Holds->search(
        {
            biblionumber   => $item->biblionumber,
            itemnumber     => $self->{item}->id,
            borrowernumber => $patron->borrowernumber
        }
    );
    return $self unless $holds->count;

    $holds->next->cancel;

	$self->ok(1);
	return $self;
}

sub change_hold {
	my $self = shift;
	unless ($self->{patron}) {
		$self->screen_msg('change_hold called with undefined patron');
		$self->ok(0);
		return $self;
	}
    my $patron = Koha::Patrons->find( { cardnumber => $self->{patron}->id } );
    unless ($patron) {
		$self->screen_msg('No borrower matches cardnumber "' . $self->{patron}->id . '".');
		$self->ok(0);
		return $self;
	}
    my $item = Koha::Items->find({ barcode => $self->{item}->id });
    unless ($item) {
		$self->screen_msg('No biblio record matches barcode "' . $self->{item}->id . '".');
		$self->ok(0);
		return $self;
	}
	my $branch = ($self->pickup_location || $self->{patron}->branchcode);
	unless ($branch) {
		$self->screen_msg('No branch specified (or found w/ patron).');
		$self->ok(0);
		return $self;
	}
    ModReserve({ biblionumber => $item->biblionumber, borrowernumber => $patron->borrowernumber, branchcode => $branch });

	$self->ok(1);
	return $self;
}

1;
__END__
