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

my $hash_ref = $obj->version_info(module => 'Test::More');

my $control = $Test::More::VERSION;

like($hash_ref->{'Test::More'}->{cur_ver}, qr/\d/, 'returns numeric version');

ok($hash_ref->{'Test::More'}->{cur_ver} == $control, 'returns correct version');


