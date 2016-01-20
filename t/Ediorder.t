#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::More tests => 6;

BEGIN { use_ok('Koha::Edifact::Order') }


# The following tests are for internal methods but they could
# error spectacularly so yest
# Check that quoting is done correctly
#
my $processed_text =
  Koha::Edifact::Order::encode_text(q{string containing ?,',:,+});

cmp_ok(
    $processed_text, 'eq',
    q{string containing ??,?',?:,?+},
    'Outgoing text correctly quoted'
);

# extend above test to test chunking in imd_segment
#
my $code           = '010';
my $data_to_encode = $processed_text;

my @segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );

my $testseg = "IMD+L+010+:::$processed_text";
$testseg .= q{'};    # add segment terminator

cmp_ok( $segs[0], 'eq', $testseg, 'IMD segment correctly formed' );

$data_to_encode = 'A' x 35;
$data_to_encode .= 'B' x 35;
$data_to_encode .= 'C' x 10;

@segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );

cmp_ok(
    $segs[0],
    'eq',
q{IMD+L+010+:::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'},
    'IMD segment correctly chunked'
);
cmp_ok( $segs[1], 'eq', q{IMD+L+010+:::CCCCCCCCCC'},
    'IMD segment correctly split across segments' );

$data_to_encode .= '??';

# this used to cause an infinite loop
@segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );
cmp_ok( $segs[1], 'eq', q{IMD+L+010+:::CCCCCCCCCC??'},
    'IMD segment deals with quoted character at end' );
