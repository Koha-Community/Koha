#
#
#
#

package Sip::Configuration::Account;

use strict;
use warnings;
use English;
# use Exporter;

sub new {
    my ($class, $obj) = @_;
    my $type = ref($class) || $class;

    if (ref($obj) eq "HASH") {
	# Just bless the object
	return bless $obj, $type;
    }

    return bless {}, $type;
}

sub id {
    my $self = shift;
    return $self->{id};
}

sub institution {
    my $self = shift;
    return $self->{institution};
}

sub password {
    my $self = shift;
    return $self->{password};
}

1;
