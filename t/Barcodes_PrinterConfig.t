#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
        use_ok('C4::Barcodes::PrinterConfig');
}

is(C4::Barcodes::PrinterConfig::setPositionsForY(), "0", "testing setPositionsForY returns'0' when given no arguments");
is(C4::Barcodes::PrinterConfig::setPositionsForX(), "0", "testing setPositionsForX returns'0' when given no arguments");

is(C4::Barcodes::PrinterConfig::setPositionsForY(undef, undef, 5), "5", "testing setPositionsForY returns'5' when given (undef, undef, 5)");
is(C4::Barcodes::PrinterConfig::setPositionsForX(undef, undef, 5), "5", "testing setPositionsForX returns'5' when given (undef, undef, 5)");


is(C4::Barcodes::PrinterConfig::labelsPage(), "0", "testing labelsPage returns'0' when given no arguments");
