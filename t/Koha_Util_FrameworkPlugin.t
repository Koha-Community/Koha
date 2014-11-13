#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 6;

use_ok( 'Koha::Util::FrameworkPlugin', qw(wrapper) );

my $char;
is($char=wrapper(' '),'space',"Return space");
is($char=wrapper('  '),'dblspace',"Return dblspace");
is($char=wrapper('|'),'pipe',"Return pipe");
is($char=wrapper('||'),'dblpipe',"Return dblpipe");
is($char=wrapper('somethingelse'),'somethingelse',"Return somethingelse");
