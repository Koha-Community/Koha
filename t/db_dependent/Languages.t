#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 5;

BEGIN {
        use_ok('C4::Languages');
}

isnt(C4::Languages::_get_themes(), undef, 'testing _get_themes doesnt return undef');

ok(C4::Languages::_get_language_dirs(), 'test getting _get_language_dirs');

is(C4::Languages::accept_language(),undef, 'test that accept_languages returns undef when nothing is entered');

ok(C4::Languages::getAllLanguages(), 'test get all languages');
