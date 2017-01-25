#!/usr/bin/perl
#
use strict;
use warnings;

use Test::More tests => 4;
use Data::Dumper;

BEGIN {
    use_ok('C4::Installer::PerlModules');
}

my $obj = C4::Installer::PerlModules->new;

isa_ok($obj,'C4::Installer::PerlModules');

my $module_info = $obj->version_info('Test::More');

my $control = $Test::More::VERSION;

like($module_info->{cur_ver}, qr/\d/, 'returns numeric version');

is($module_info->{cur_ver}, $control, 'returns correct version');


