#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::NoWarnings;
use Test::More tests => 14;
use t::lib::Mocks;

BEGIN { use_ok('Koha::Edifact::Order') }
t::lib::Mocks::mock_preference( 'EdifactLSQ', 'location' );

# The following tests are for internal methods but they could
# error spectacularly so best
# Check that quoting is done correctly
#
my $processed_text = Koha::Edifact::Order::encode_text(q{string containing ?,',:,+});

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
cmp_ok(
    $segs[1], 'eq', q{IMD+L+010+:::CCCCCCCCCC'},
    'IMD segment correctly split across segments'
);

$data_to_encode .= '??';

# this used to cause an infinite loop
@segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );
cmp_ok(
    $segs[1], 'eq', q{IMD+L+010+:::CCCCCCCCCC??'},
    'IMD segment deals with quoted character at end'
);

# special case for text ending in apostrophe e.g. nuthin'
$data_to_encode .= q{?'};
@segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );
cmp_ok(
    $segs[1], 'eq',
    q{IMD+L+010+:::CCCCCCCCCC???''},
    'IMD segment deals with quoted apostrophe at end'
);

$data_to_encode =~ s/\?'$//;
@segs = Koha::Edifact::Order::imd_segment( $code, $data_to_encode );
cmp_ok(
    $segs[1], 'eq', q{IMD+L+010+:::CCCCCCCCCC??'},
    'IMD segment deals with apostrophe preceded by quoted ?  at end'
);

my $isbn = '3540556753';
my $ean  = '9783540556756';

my $seg = Koha::Edifact::Order::additional_product_id($isbn);
cmp_ok(
    $seg, 'eq', q{PIA+5+3540556753:IB'},
    'isbn correctly encoded in PIA segment'
);

$seg = Koha::Edifact::Order::additional_product_id($ean);
cmp_ok(
    $seg, 'eq', q{PIA+5+9783540556756:EN'},
    'ean correctly encoded in PIA segment'
);

my $orderfields = { budget_code => 'BUDGET', };
my @items       = (
    {
        itype          => 'TYPE',
        location       => 'LOCATION',
        itemcallnumber => 'CALL',
        branchcode     => 'BRANCH',
    },
    {
        itype          => 'TYPE',
        location       => 'LOCATION',
        itemcallnumber => 'CALL',
        branchcode     => 'BRANCH',
    }
);

my @gsegs = Koha::Edifact::Order::gir_segments(
    {
        ol_fields => $orderfields,
        items     => \@items
    }
);
cmp_ok(
    $gsegs[0], 'eq',
    q{GIR+001+BUDGET:LFN+BRANCH:LLO+TYPE:LST+LOCATION:LSQ+CALL:LSM},
    'Single Gir field OK'
);

$orderfields->{servicing_instruction} = 'S_I';
@gsegs = Koha::Edifact::Order::gir_segments(
    {
        ol_fields => $orderfields,
        items     => \@items
    }
);
cmp_ok(
    $gsegs[2], 'eq',
    q{GIR+002+BUDGET:LFN+BRANCH:LLO+TYPE:LST+LOCATION:LSQ+CALL:LSM},
    'First part of split Gir field OK'
);

cmp_ok(
    $gsegs[3], 'eq', q{GIR+002+S_I:LVT},
    'Second part of split GIR field OK'
);
