#!/usr/bin/perl

use strict;
use warnings;

my $string = $ARGV[0];

# Getting the marcfields as an array
    my @marcfieldsarray = split('\|', $string);

    # Separating the marcfields from the the user-supplied headers
    my @marcfields;
    foreach (@marcfieldsarray) {
        my @result = split('=', $_);
	if (scalar(@result) == 2) {
	   push @marcfields, { header => $result[0], field => $result[1] }; 
	} else {
	   push @marcfields, { field => $result[0] }
	}
    }

use Data::Dumper;
print Dumper(@marcfields);


foreach (@marcfields) {
    print $_->{field};
}


