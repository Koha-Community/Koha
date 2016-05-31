#!/usr/bin/perl
#
# This module will excercise pdf creation routines
#
# When run with KEEP_PDF enviroment variable it will keep
# test.pdf for manual inspection. This can be used to verify
# that ttf font configuration is complete like:
#
# KEEP_PDF=1 KOHA_CONF=/etc/koha/sites/srvgit/koha-conf.xml prove t/Creators.t
#
# sample of utf-8 text, font name and type will be on bottom of second page

use strict;
use warnings;

use File::Temp qw/ tempfile  /;
use Test::More tests => 41;

BEGIN {
        use_ok('C4::Creators');
        use_ok('C4::Creators::PDF');
}

my $pdf_creator = C4::Creators::PDF->new(InitVars => 0);
ok($pdf_creator, "testing new() works");
if (-e $pdf_creator->{filename}) {
  pass('testing pdf file created');
}
else {
  fail('testing pdf file created');
}

ok($pdf_creator->Add(""), "testing Add() works");
ok($pdf_creator->Bookmark({}), "testing Bookmark() works");
ok($pdf_creator->Compress(1), "testing Compress() works");

is($pdf_creator->Font("H"), "Ft1", "testing Font() works");
is($pdf_creator->FontSize(), '12', "testing FontSize() is set to 12 by default");
my @result = $pdf_creator->FontSize(14);
is($result[0], '14', "testing FontSize() can be set to a different value");
$pdf_creator->FontSize(); # Reset font size before testing text width etc below

ok($pdf_creator->Page(), "testing Page() works");

my $expected_width;
my $expected_offset;
if (C4::Context->config('ttf')) {
    $expected_width  = '23.044921875';
    $expected_offset = '33.044921875';
} else {
    $expected_width  = '19.344';
    $expected_offset = '29.344';
}

is($pdf_creator->StrWidth("test", "H", 12), $expected_width, "testing StrWidth() returns correct point width");

@result = $pdf_creator->Text(10, 10, "test");
is($result[0], '10', "testing Text() writes from a given x-value");
is($result[1], $expected_offset, "testing Text() writes to the correct x-value");

my $font_types = C4::Creators::Lib::get_font_types();
isa_ok( $font_types, 'ARRAY', 'get_font_types' );

my $y = 50;
foreach my $font ( @$font_types ) {
	ok( $pdf_creator->Font( $font->{type} ), 'Font ' . $font->{type} );
	ok( $pdf_creator->Text(10, $y, "\x{10C}evap\x{10D}i\x{107} " . $font->{name} . ' - ' . $font->{type} ), 'Text ' . $font->{name});
	$y += $pdf_creator->FontSize() * 1.2;
}

SKIP: {
    skip "Skipping because without proper fonts these two tests fail",
        2 if ! $ENV{KOHA_CONF};

    my  ($fh, $filename) = tempfile();
    open(  $fh, '>', $filename );
    select $fh;

    ok($pdf_creator->End(), "testing End() works");

    close($fh);
    ok( -s $filename , "test file $filename created OK" );
    unlink $filename unless $ENV{KEEP_PDF};
}
