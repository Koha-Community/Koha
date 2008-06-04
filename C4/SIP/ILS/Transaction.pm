#
# Transaction: Superclass of all the transactional status objects
#

package ILS::Transaction;

use Carp;
use strict;
use warnings;
use C4::Context;

my %fields = (
	ok            => 0,
	patron        => undef,
	item          => undef,
	desensitize   => 0,
	alert         => '',
	transaction_id=> undef,
	sip_fee_type  => '01', # Other/Unknown
	fee_amount    => undef,
	sip_currency  => 'USD', # FIXME: why hardcoded?
	screen_msg    => '',
	print_line    => '',
);

our $AUTOLOAD;

sub new {
	my $class = shift;
	my $self = {
		_permitted => \%fields,
		%fields,
	};
	return bless $self, $class;
}

sub DESTROY {
    # be cool
}

sub AUTOLOAD {
    my $self = shift;
    my $class = ref($self) or croak "$self is not an object";
    my $name = $AUTOLOAD;

    $name =~ s/.*://;

    unless (exists $self->{_permitted}->{$name}) {
		croak "Can't access '$name' field of class '$class'";
    }

	if (@_) {
		return $self->{$name} = shift;
	} else {
		return $self->{$name};
	}
}

1;
__END__

