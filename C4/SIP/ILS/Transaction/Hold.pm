#
# status of a Hold transaction

package ILS::Transaction::Hold;

use warnings;
use strict;

use ILS;
use ILS::Transaction;

use C4::Reserves;	# AddReserve
use C4::Members;	# GetMember
use C4::Biblio;		# GetBiblioFromItemNumber GetBiblioItemByBiblioNumber

use vars qw($VERSION @ISA);

BEGIN {
    $VERSION = 1.01;
	    @ISA = qw(ILS::Transaction);
}

my %fields = (
	expiration_date => 0,
	pickup_location => undef,
	constraint_type => undef,
);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	my $element;
	foreach $element (keys %fields) {
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
	unless ($self->{patron}) {
		$self->screen_msg('do_hold called with undefined patron');
		$self->ok(0);
		return $self;
	}
	my $borrower = GetMember( $self->{patron}->id, 'cardnumber');
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
	AddReserve($branch, $borrower->{borrowernumber}, 
				$bibno, 'a', GetBiblioItemByBiblioNumber($bibno)) ;
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
	my $borrower = GetMember( $self->{patron}->id, 'cardnumber');
	unless ($borrower) {
		$self->screen_msg('No borrower matches cardnumber "' . $self->{patron}->id . '".');
		$self->ok(0);
		return $self;
	}
	my $bib = GetBiblioFromItemNumber(undef, $self->{item}->id);
	# FIXME: figure out if it is a item or title hold.  Till then, cancel both.
	CancelReserve($bib->{biblionumber}, undef, $borrower->{borrowernumber});
	CancelReserve(undef, $self->{item}->id, $borrower->{borrowernumber});
		# unfortunately no meaningful return value here either
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
	my $borrower = GetMember( $self->{patron}->id, 'cardnumber');
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
	ModReserve($bibno, $borrower->{borrowernumber}, $branch, GetBiblioItemByBiblioNumber($bibno));
		# unfortunately no meaningful return value
		# ModReserve needs to be fixed to maintain priority by iteself (Feb 2008)
	$self->ok(1);
	return $self;
}
1;
__END__

# 10 friggin arguments
AddReserve($branch,$borrowernumber,$biblionumber,$constraint,$bibitems,$priority,$notes,$title,$checkitem,$found)

ModReserve($rank, $biblio, $borrower, $branch , $itemnumber)

