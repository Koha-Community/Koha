#!/usr/bin/perl -w

# $Id$

BEGIN {
    my $intranetdir=`grep intranetdir /etc/koha.conf`;
    chomp $intranetdir;
    $intranetdir=~s/\s*intranetdir\s*=\s*//i;
    $::modulesdir=$intranetdir."/modules";
}

use lib $::modulesdir;

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
	't/webscripts/circulation.t',
);


runtests (@tests);

exit;

# $Log$
# Revision 1.1.2.10  2002/10/29 20:22:38  tonnesen
# buildrelease now puts the test scripts in $intranetdir/scripts/t/
#
# Revision 1.1.2.9  2002/10/29 19:47:57  tonnesen
# New test script for circulation module.
#
# Revision 1.1.2.8  2002/10/29 19:26:27  tonnesen
# Added some more tests to catalog.t
#
# Revision 1.1.2.7  2002/06/20 15:19:33  amillar
# Test valid ISBN numbers in Input.pm
#
