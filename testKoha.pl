#!/usr/bin/perl -w

# $Id$

use strict;
use Test::Harness;

# please add many tests here
# Please make the test name the same as the module name where possible

my @tests=(
	't/format.t',
	't/Input.t',
	't/koha.t',
	't/output.t',
	't/require.t',
	't/webscripts/catalog.t',
);


runtests (@tests);

exit;

# $Log$
# Revision 1.1.2.8  2002/10/29 19:26:27  tonnesen
# Added some more tests to catalog.t
#
# Revision 1.1.2.7  2002/06/20 15:19:33  amillar
# Test valid ISBN numbers in Input.pm
#
