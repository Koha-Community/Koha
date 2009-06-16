#!/usr/bin/perl
#

use warnings;
use strict;

use ILS::Item;
use Data::Dumper;

my $compare = (@ARGV) ? shift : 0;
while (1) {
	print "Enter item barcode: ";
	my $in = <>;
	defined($in) or last;
	chomp($in);
	last unless $in;
	my $item = ILS::Item->new($in);
    unless ($item) {
        print "No item ($in)";
        next;
    }
    for (qw(marc marcxml)) {
        $item->{$_} = 'suppressed...';
    }
    my $queue = $item->hold_queue();
    print "Item ($in): ", Dumper($item);
    print "hold_queue: ", Dumper($queue);
    my $holdernumber;
	if ($queue and scalar(@$queue)) {
        $holdernumber = $queue->[0]->{borrowernumber};
        print "first borrowernumber: $holdernumber\n";
    }
    if ($compare) {
        print "Enter patron barcode: ";
        my $barcode = <>;
        defined($barcode) or next;
        chomp($barcode);
        next unless $barcode;
        my $x = ILS::Item::_barcode_to_borrowernumber($barcode) || 'UNDEF';
        print  "         converts to: $x\n";
        printf "         compares as: %s\n", 
            ($item->barcode_is_borrowernumber($barcode,$holdernumber) ? 'TRUE' : 'FALSE');
    }
}
