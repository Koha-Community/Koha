#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::NoWarnings;
use Test::More tests => 53;
use Koha::EDI;

BEGIN {
    use_ok('Koha::Edifact');
    use_ok('Koha::Edifact::Message');
}

my $filename = "$Bin/edi_testfiles/prquotes_73050_20140430.CEQ";

my $quote = Koha::Edifact->new( { filename => $filename, } );

isa_ok( $quote, 'Koha::Edifact' );

my $x = $quote->interchange_header('sender');
is( $x, '5013546027856', "sender returned" );

$x = $quote->interchange_header('recipient');
is( $x, '5030670137480', "recipient returned" );
$x = $quote->interchange_header('datetime');
is( $x->[0], '140430', "datetime returned" );
my $control_reference = 'EDIQ2857763';
$x = $quote->interchange_header('interchange_control_reference');
is( $x, $control_reference, "interchange_control_reference returned" );

$x = $quote->interchange_header('application_reference');
is( $x, 'QUOTES', "application_reference returned" );

$x = $quote->interchange_trailer('interchange_control_count');
is( $x, 1, "interchange_control_count returned" );

my $msgs      = $quote->message_array();
my $msg_count = @{$msgs};
is( $msg_count, 1, "correct message count returned" );
my $m = $msgs->[0];

is( $m->message_type, 'QUOTES', "Message shows correct type" );
is(
    $m->message_reference_number,
    'MQ09791', "Message reference number returned"
);
is( $m->docmsg_number, 'Q741588',       "Message docmsg number returned" );
is( $m->message_date,  '20140430',      "Message date returned" );
is( $m->buyer_ean,     '5030670137480', 'buyer ean returned' );

my $lin = $m->lineitems();

my $num_lines = @{$lin};
is( $num_lines, 18, 'Correct number of lines in message' );

my $test_line = $lin->[-1];

is( $test_line->line_item_number,     18,              'correct line number returned' );
is( $test_line->item_number_id,       '9780273761006', 'correct ean returned' );
is( $test_line->quantity,             1,               'quantity returned' );
is( $test_line->price_info,           114.97,          'price returned' );
is( $test_line->price_info_inclusive, undef,           'discounted price undefined as expected' );

my $test_title = 'International business [electronic resource]';
my $marcrec    = $test_line->marc_record;
isa_ok( $marcrec, 'MARC::Record' );

my $title = $test_line->title();

# also tests components are concatenated
is( $title, $test_title, "Title returned" );

# problems currently with the record (needs leader ??)
#is( $marcrec->title(), $test_title, "Title returned from marc");
my $test_author = q{Rugman, Alan M.};
is( $test_line->author,           $test_author,        "Author returned" );
is( $test_line->publisher,        'Pearson Education', "Publisher returned" );
is( $test_line->publication_date, q{2012.},            "Pub. date returned" );
#
# Test data encoded in GIR
#
my $stock_category = $test_line->girfield('stock_category');
is( $stock_category, 'EBOOK', "stock_category returned" );
my $branch = $test_line->girfield('branch');
is( $branch, 'ELIB', "branch returned" );
my $fund_allocation = $test_line->girfield('fund_allocation');
is( $fund_allocation, '660BOO_2013', "fund_allocation returned" );
my $sequence_code = $test_line->girfield('sequence_code');
is( $sequence_code, 'EBOO', "sequence_code returned" );

#my $shelfmark = $test_line->girfield('shelfmark');
#my $classification = $test_line->girfield('classification');

## text the free_text returned from the line
my $test_line_2 = $lin->[12];

my $ftx_string = 'E*610.72* - additional items';

is( $test_line_2->orderline_free_text, $ftx_string, "ftx note retrieved" );

my $filename2 = "$Bin/edi_testfiles/QUOTES_413514.CEQ";

my $q2       = Koha::Edifact->new( { filename => $filename2, } );
my $messages = $q2->message_array();

my $orderlines = $messages->[0]->lineitems();

my $ol = $orderlines->[0];

my $y = $ol->girfield( 'copy_value', 5 );

is( $y, undef, 'No extra item generated' );

$y = $ol->girfield( 'copy_value', 1 );
is( $y, '16.99', 'Copy Price returned' );

$y = $ol->girfield( 'classification', 4 );
is( $y, '914.1061', 'Copy classification returned' );

$y = $ol->girfield( 'fund_allocation', 4 );
is( $y, 'REF', 'Copy fund returned' );

$y = $ol->girfield( 'branch', 4 );
is( $y, 'SOU', 'Copy Branch returned' );

$y = $ol->girfield( 'sequence_code', 4 );
is( $y, 'ANF', 'Sequence code returned' );

$y = $ol->girfield( 'stock_category', 4 );
is( $y, 'RS', 'Copy stock category returned' );

$y = $ol->girfield( 'library_rotation_plan', 0 );
is( $y, 'WRPC2', 'Library rotation plan returned' );

# test internal routines for prices
my $dp = Koha::EDI::_discounted_price( 33.0, 9 );
is( $dp, 6.03, 'Discount calculated' );

$dp = Koha::EDI::_discounted_price( 0.0, 9 );
is( $dp, 9.0, 'Discount calculated with discount = 0' );

$dp = Koha::EDI::_discounted_price( 0.0, 9, 8.0 );
is( $dp, 8.0, 'Discount overridden by incoming calculated value' );

# Test RFF+ON (Purchase Order Number) segment handling in EDIFACT messages
# Bug 20253: Optionally use buyer's purchase order number from EDIFACT quote in basket name

# Mock segment class for testing RFF+ON functionality
{

    package MockSegment;

    sub new {
        my ( $class, $tag, $elements ) = @_;
        return bless { tag => $tag, elements => $elements }, $class;
    }

    sub tag {
        my $self = shift;
        return $self->{tag};
    }

    sub elem {
        my ( $self, $comp_pos, $elem_pos ) = @_;
        return $self->{elements}->[$comp_pos]->[ $elem_pos // 0 ];
    }
}

# Test that message-level purchase order number is extracted correctly
my @datasegs = (
    MockSegment->new( 'NAD', [ ['BY'], [ '5030670137480', '', '', 'Buyer Name' ] ] ),
    MockSegment->new( 'RFF', [ [ 'ON', 'MSG_PO_12345' ] ] ),    # Message-level purchase order number
    MockSegment->new( 'NAD', [ ['SU'], [ '5013546027856', '', '', 'Supplier Name' ] ] ),
    MockSegment->new( 'LIN', [ ['1'], [ '', '' ], [ '9780123456789', 'EN' ] ] ),           # First line item
    MockSegment->new( 'QTY', [ [ '47', '1' ] ] ),
);

my $header = MockSegment->new( 'UNH', [ ['MQ09791'], [ 'QUOTES', 'D', '03B', 'UN', 'EAN008' ] ] );
my $bgm    = MockSegment->new( 'BGM', [ [ '310', 'Q741588', '9' ] ] );

my $message = Koha::Edifact::Message->new( [ $header, $bgm, @datasegs ] );
is(
    $message->purchase_order_number, 'MSG_PO_12345',
    'Message-level purchase order number extracted from RFF+ON segment'
);

# Test that RFF+ON processing stops at first LIN segment (message-level only)
@datasegs = (
    MockSegment->new( 'NAD', [ ['BY'], [ '5030670137480', '', '', 'Buyer Name' ] ] ),
    MockSegment->new( 'LIN', [ ['1'], [ '', '' ], [ '9780123456789', 'EN' ] ] ),        # First LIN
    MockSegment->new( 'RFF', [ [ 'ON', 'AFTER_LIN_PO' ] ] ),    # This should be ignored (line-level)
    MockSegment->new( 'QTY', [ [ '47', '1' ] ] ),
);

$message = Koha::Edifact::Message->new( [ $header, $bgm, @datasegs ] );
is( $message->purchase_order_number, undef, 'RFF+ON after LIN segment is ignored (message-level only)' );

# Test that correct RFF+ON is extracted when multiple RFF segments are present
@datasegs = (
    MockSegment->new( 'NAD', [ ['BY'], [ '5030670137480', '', '', 'Buyer Name' ] ] ),
    MockSegment->new( 'RFF', [ [ 'QLI', 'QUOTE_REF_123' ] ] ),     # Different RFF qualifier
    MockSegment->new( 'RFF', [ [ 'ON',  'CORRECT_PO_NUM' ] ] ),    # Purchase order number
    MockSegment->new( 'RFF', [ [ 'CT',  'CONTRACT_456' ] ] ),      # Another different RFF qualifier
    MockSegment->new( 'NAD', [ ['SU'], [ '5013546027856', '', '', 'Supplier Name' ] ] ),
    MockSegment->new( 'LIN', [ ['1'], [ '', '' ], [ '9780123456789', 'EN' ] ] ),
    MockSegment->new( 'QTY', [ [ '47', '1' ] ] ),
);

$message = Koha::Edifact::Message->new( [ $header, $bgm, @datasegs ] );
is( $message->purchase_order_number, 'CORRECT_PO_NUM', 'Correct RFF+ON extracted when multiple RFF segments present' );

# Test LSL (Library Sub-Location) field extraction from GIR segments
my $mock_line_data = {
    GIR => [
        {
            copy              => '001',
            sub_location_code => 'FICTION',    # LSL field
            sequence_code     => 'ADULT',      # LSQ field
            branch            => 'MAIN'
        },
        {
            copy              => '002',
            sub_location_code => 'REFERENCE',    # LSL field
            branch            => 'BRANCH2'

                # sequence_code missing for this item
        }
    ]
};

my $mock_line = bless $mock_line_data, 'Koha::Edifact::Line';

# Test LSL field access via girfield method
$y = $mock_line->girfield('sub_location_code');
is( $y, 'FICTION', 'LSL field (sub_location_code) returned for first occurrence' );

$y = $mock_line->girfield( 'sub_location_code', 0 );
is( $y, 'FICTION', 'LSL field returned for explicit occurrence 0' );

$y = $mock_line->girfield( 'sub_location_code', 1 );
is( $y, 'REFERENCE', 'LSL field returned for occurrence 1' );

$y = $mock_line->girfield( 'sub_location_code', 2 );
is( $y, undef, 'LSL field returns undef for non-existent occurrence' );

# Test that both LSL and LSQ can coexist
$y = $mock_line->girfield( 'sequence_code', 0 );
is( $y, 'ADULT', 'LSQ field still works when LSL is present' );

$y = $mock_line->girfield( 'sequence_code', 1 );
is( $y, undef, 'LSQ field correctly returns undef when not present for occurrence' );

# Test LSL field when LSQ is missing
$y = $mock_line->girfield( 'sub_location_code', 1 );
is( $y, 'REFERENCE', 'LSL field works correctly when LSQ is missing for that occurrence' );
