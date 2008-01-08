#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use override_context_prefs;
        use_ok('C4::Biblio');
}

