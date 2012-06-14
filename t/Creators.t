#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 16;

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

is($pdf_creator->StrWidth("test", "H", 12), '19.344', "testing StrWidth() returns correct point width");

@result = $pdf_creator->Text(10, 10, "test");
is($result[0], '10', "testing Text() writes from a given x-value");
is($result[1], '29.344', "testing Text() writes to the correct x-value");

open(my $fh, '>', 'test.pdf');
select $fh;

ok($pdf_creator->End(), "testing End() works");

close($fh);
ok( -s 'test.pdf', 'test.pdf created' );

unlink 'test.pdf';
