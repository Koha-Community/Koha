#
# An object to handle checkin status
#

package ILS::Transaction::Checkin;

use warnings;
use strict;

use POSIX qw(strftime);

use ILS;
use ILS::Transaction;

our @ISA = qw(ILS::Transaction);

my %fields = (
	      magnetic => 0,
	      sort_bin => undef,
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

sub resensitize {
    my $self = shift;

    return !$self->{item}->magnetic;
}

1;
