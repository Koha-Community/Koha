#!/usr/bin/perl
#

use warnings;
use strict;

use ILS::Patron;
use Sip qw(sipbool);
use Data::Dumper;

while (1) {
	print "Enter patron barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $patron = ILS::Patron->new($in);
	print Dumper($patron);
	$patron or next;
	print "Enter patron password: ";
	$in = <>;
	chomp($in);
	print "Raw password is: " . $patron->{password}, "\n"; 
	print " check_password: " . $patron->check_password($in), "\n"; 
	print "        sipbool: " . sipbool($patron->check_password($in)), "\n"; 
}
