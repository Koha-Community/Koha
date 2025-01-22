#!/usr/bin/perl
#
# This module tests the HtmlTag filter
#

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 5;

BEGIN { use_ok('Koha::Template::Plugin::HtmlTags'); }

my $filter = Koha::Template::Plugin::HtmlTags->new();
ok( $filter, "new()" );

# Test simple tag
my $expected = '<h1>TEST</h1>';
my $created  = $filter->filter( 'TEST', '', { tag => 'h1' } );
is( $created, $expected, "Testing simple tag works: $expected - $created" );

# Test tag with attributes
$expected = '<h1 class="MYCLASS" title="MYTITLE">TEST</h1>';
$created  = $filter->filter( 'TEST', '', { tag => 'h1', attributes => 'class="MYCLASS" title="MYTITLE"' } );
is( $created, $expected, "Testing tag with attributes works: $expected - $created" );
