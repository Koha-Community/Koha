#!/usr/bin/perl
#
use strict;
use warnings;

use Test::More tests => 2;
use Data::Dumper;

BEGIN {
    use_ok('C4::Installer::PerlModules');
}

my $obj = C4::Installer::PerlModules->new;

isa_ok($obj,'C4::Installer::PerlModules');
