#!/usr/bin/perl
#

use warnings;
use strict;

use ILS::Item;
use Data::Dumper;

while (1) {
	print "Enter item barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $patron = ILS::Item->new($in);
	print Dumper($patron);
}
