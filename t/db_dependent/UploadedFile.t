#!/usr/bin/perl
#

# A simple test for UploadedFile
# only ->new is covered

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
        use_ok('C4::UploadedFile');
}

ok(my $file = C4::UploadedFile->new());
