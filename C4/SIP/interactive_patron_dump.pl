#!/usr/bin/perl
#

use warnings;
use strict;

use ILS::Patron;
use Data::Dumper;

while (1) {
	print "Enter patron barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $patron = ILS::Patron->new($in);
	print Dumper($patron);
}
