#
# status of a Hold transaction

package C4::SIP::ILS::Transaction::Hold;

use warnings;
use strict;

use C4::SIP::ILS::Transaction;

use C4::Reserves;	# AddReserve
use C4::Members;	# GetMember
use C4::Biblio;		# GetBiblioFromItemNumber GetBiblioItemByBiblioNumber
use parent qw(C4::SIP::ILS::Transaction);



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
    my $borrower = GetMember( 'cardnumber' => $self->{patron}->id );
    unless ($borrower) {
        $self->screen_msg( 'No borrower matches cardnumber "' . $self->{patron}->id . '".' );
        $self->ok(0);
        return $self;
    }
    my $bib = GetBiblioFromItemNumber( undef, $self->{item}->id );
    unless ($bib) {
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
    my $bibno = $bib->{biblionumber};
    AddReserve( $branch, $borrower->{borrowernumber}, $bibno, GetBiblioItemByBiblioNumber($bibno) );

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
	my $borrower = GetMember( 'cardnumber'=>$self->{patron}->id);
	unless ($borrower) {
		$self->screen_msg('No borrower matches cardnumber "' . $self->{patron}->id . '".');
		$self->ok(0);
		return $self;
	}
	my $bib = GetBiblioFromItemNumber(undef, $self->{item}->id);

      CancelReserve({
            biblionumber   => $bib->{biblionumber},
        itemnumber     => $self->{item}->id,
           borrowernumber => $borrower->{borrowernumber}
      });

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
	my $borrower = GetMember( 'cardnumber'=>$self->{patron}->id);
	unless ($borrower) {
		$self->screen_msg('No borrower matches cardnumber "' . $self->{patron}->id . '".');
		$self->ok(0);
		return $self;
	}
	my $bib = GetBiblioFromItemNumber(undef, $self->{item}->id);
	unless ($bib) {
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
	my $bibno = $bib->{biblionumber};
	ModReserve({ biblionumber => $bibno, borrowernumber => $borrower->{borrowernumber}, branchcode => $branch });

	$self->ok(1);
	return $self;
}

1;
__END__
