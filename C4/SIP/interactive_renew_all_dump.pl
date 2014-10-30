#!/usr/bin/perl
#

use warnings;
use strict;

use C4::SIP::ILS::Transaction::RenewAll;
use Data::Dumper;

while (1) {
	print "Enter patron barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $patron = ILS::Patron->new($in);
	print "Patron before: \n " . Dumper($patron);
	my $action = C4::SIP::ILS::Transaction::RenewAll->new();
	$action->do_renew_all();
	print "\n\nTransaction::RenewAll: " . Dumper($action);
	print "\n", "=" x 35, "\n";
}
