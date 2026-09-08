#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;

use C4::Context;

my $original = C4::Context->preference('TagsExternalDictionary');

C4::Context->set_preference( 'TagsExternalDictionary', '/usr/bin/ispell' );

lives_ok { require C4::Tags } 'C4::Tags compiles when TagsExternalDictionary is configured';

# Restore the original preference
C4::Context->set_preference( 'TagsExternalDictionary', $original // q{} );
