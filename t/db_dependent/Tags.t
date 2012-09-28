#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 30;

BEGIN {
        use_ok('C4::Tags');
}

# Simple 'sequential 5' test
my $tags = make_tags(1,2,3,4,5);
my @strata = (0,1,2,3,4);
my ($min, $max) = C4::Tags::stratify_tags(5, $tags);
check_tag_strata($tags, \@strata, 'Sequential 5');
is($min, 0, 'Sequential 5 min');
is($max, 4, 'Sequential 5 max');

# Reverse test - should have the same results as previous
$tags = make_tags(5,4,3,2,1);
@strata = (4,3,2,1,0);
($min, $max) = C4::Tags::stratify_tags(5, $tags);
check_tag_strata($tags, \@strata, 'Reverse Sequential 5');
is($min, 0, 'Sequential 5 min');
is($max, 4, 'Sequential 5 max');

# All the same test - should all have the same results
$tags = make_tags(4,4,4,4,4);
@strata = (0,0,0,0,0);
($min, $max) = C4::Tags::stratify_tags(5, $tags);
check_tag_strata($tags, \@strata, 'All The Same');
is($min, 0, 'Sequential 5 min');
is($max, 0, 'Sequential 5 max');

# Some the same, some different
$tags = make_tags(1,2,2,3,3,8);
@strata = (0,0,0,1,1,4);
($min, $max) = C4::Tags::stratify_tags(5, $tags);
check_tag_strata($tags, \@strata, 'All The Same');
is($min, 0, 'Sequential 5 min');
is($max, 7, 'Sequential 5 max');

# Runs tests against the results
sub check_tag_strata {
    my ($tags, $expected, $name) = @_;

    foreach my $t (@$tags) {
        my $w = $t->{weight_total};
        my $s = $t->{stratum};
        is($s, shift @$expected, $name . " - $w ($s)");
    }
}

# Makes some tags with just enough info to test
sub make_tags {
    my @res;
    while (@_) {
        push @res, { weight_total => shift @_ };
    }
    return \@res;
}
