#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use C4::Context;

my $original = C4::Context->preference('TagsExternalDictionary');

C4::Context->set_preference( 'TagsExternalDictionary', '/usr/bin/ispell' );

my $output = qx{
    perl -I. -MC4::Tags -e 'print "loaded\n"' 2>&1
};
my $exit_status = $? >> 8;

# Restore the original preference before checking the result
C4::Context->set_preference( 'TagsExternalDictionary', $original // q{} );

is(
    $exit_status,
    0,
    'C4::Tags loads when TagsExternalDictionary is configured'
);

like(
    $output,
    qr/loaded/,
    'C4::Tags finished loading successfully'
);
