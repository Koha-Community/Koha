#!/usr/bin/perl
#

use warnings;
use strict;

use C4::SIP::ILS::Patron;
use Data::Dumper;

while (1) {
	print "Enter patron barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $patron = C4::SIP::ILS::Patron->new($in);
	print "Patron ($in):\n", Dumper($patron);
}
