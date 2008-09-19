package ILS::Transaction::FeePayment;

use warnings;
use strict;

use vars qw($VERSION @ISA $debug);

BEGIN {
	$VERSION = 1.00;
	@ISA = qw(ILS::Transaction);
	$debug = 0;
}

use ILS;
use ILS::Transaction;

1;
__END__

