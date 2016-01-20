#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::More tests => 34;

BEGIN { use_ok('Koha::Edifact') }

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
is( $m->message_reference_number,
    'MQ09791', "Message reference number returned" );
is( $m->docmsg_number, 'Q741588',  "Message docmsg number returned" );
is( $m->message_date,  '20140430', "Message date returned" );

my $lin = $m->lineitems();

my $num_lines = @{$lin};
is( $num_lines, 18, 'Correct number of lines in message' );

my $test_line = $lin->[-1];

is( $test_line->line_item_number, 18, 'correct line number returned' );
is( $test_line->item_number_id, '9780273761006', 'correct ean returned' );
is( $test_line->quantity, 1, 'quantity returned' );

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
my $collection_code = $test_line->girfield('collection_code');
is( $collection_code, 'EBOO', "collection_code returned" );

#my $shelfmark = $test_line->girfield('shelfmark');
#my $classification = $test_line->girfield('classification');

## text the free_text returned from the line
my $test_line_2 = $lin->[12];

my $ftx_string = 'E*610.72* - additional items';

is( $test_line_2->orderline_free_text, $ftx_string, "ftx note retrieved" );

my $filename2 = "$Bin/edi_testfiles/QUOTES_413514.CEQ";

my $q2 = Koha::Edifact->new( { filename => $filename2, } );
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

$y = $ol->girfield( 'collection_code', 4 );
is( $y, 'ANF', 'Collection code returned' );

$y = $ol->girfield( 'stock_category', 4 );
is( $y, 'RS', 'Copy stock category returned' );
