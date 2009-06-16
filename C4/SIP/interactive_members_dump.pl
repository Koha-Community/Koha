#!/usr/bin/perl
#

use warnings;
use strict;

use C4::Members;
use Data::Dumper;

while (1) {
	print "Enter patron barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	print "GetMember : \n",  Dumper(GetMember($in, 'cardnumber'));
	my ($member) = GetMemberDetails(undef, $in);
	my $flags = $member->{authflags};
	print "GetMemberDetails (member) : \n", Dumper($member);
	print "GetMemberDetails ( flags) : \n", Dumper($flags);
	print "=" x 10, "\n";
}
