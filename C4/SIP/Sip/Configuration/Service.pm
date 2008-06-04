#
#
#
#

package Sip::Configuration::Service;

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

1;
