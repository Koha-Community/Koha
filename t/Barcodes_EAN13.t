#!/usr/bin/perl
#
# implementation tests are in t/db_dependent/Barcodes.t

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
        use_ok('C4::Barcodes::EAN13');
}
