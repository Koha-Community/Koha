#
# An object to handle checkin status
#

package ILS::Transaction::Checkin;

use warnings;
use strict;

# use POSIX qw(strftime);

use ILS;
use ILS::Transaction;

use C4::Circulation;

our @ISA = qw(ILS::Transaction);

my %fields = (
    magnetic => 0,
    sort_bin => undef,
    collection_code  => undef,
    # 3M extensions:
    call_number      => undef,
    destination_loc  => undef,
    alert_type       => undef,  # 00,01,02,03,04 or 99
    hold_patron_id   => undef,
    hold_patron_name => "",
    hold             => undef,
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();                # start with an ILS::Transaction object

    foreach (keys %fields) {
        $self->{_permitted}->{$_} = $fields{$_};    # overlaying _permitted
    }

    @{$self}{keys %fields} = values %fields;        # copying defaults into object
    return bless $self, $class;
}

sub do_checkin {
    my $self = shift;
    my $branch = @_ ? shift : 'SIP2' ;
    my $barcode = $self->{item}->id;
    my ($return, $messages, $iteminformation, $borrower) = AddReturn($barcode, $branch);
    $self->alert(!$return);
    if ($messages->{BadBarcode}) {
        $self->alert_type('99');
    }
    # ignoring: NotIssued, IsPermanent
    if ($messages->{wthdrawn}) {
        $self->alert_type('99');
    }
    if ($messages->{ResFound}) {
        if ($self->hold($messages->{ResFound}->{ResFound})) {
            $self->alert_type('99');
        }
    }
    $self->alert(1) if defined $self->alert_type;  # alert_type could be "00"
    $self->ok($return);
}

sub resensitize {
	my $self = shift;
	unless ($self->{item}) {
		warn "no item found in object to resensitize";
		return;
	}
	return !$self->{item}->magnetic_media;
}

sub patron_id {
	my $self = shift;
	unless ($self->{patron}) {
		warn "no patron found in object";
		return;
	}
	return $self->{patron}->id;
}

1;
