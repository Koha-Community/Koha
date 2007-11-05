#
# status of a Hold transaction

package ILS::Transaction::Hold;

use warnings;
use strict;

use ILS;
use ILS::Transaction;

our @ISA = qw(ILS::Transaction);

my %fields = (
	      expiration_date => 0,
	      pickup_location => undef,
	      );

sub new {
    my $class = shift;;
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

1;
