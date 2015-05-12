#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 7;

use_ok( 'Koha::Util::FrameworkPlugin', qw(wrapper date_entered) );

my $char;
is($char=wrapper(' '),'space',"Return space");
is($char=wrapper('  '),'dblspace',"Return dblspace");
is($char=wrapper('|'),'pipe',"Return pipe");
is($char=wrapper('||'),'dblpipe',"Return dblpipe");
is($char=wrapper('somethingelse'),'somethingelse',"Return somethingelse");

my $f008= date_entered();
is( $f008 =~ /^\d{6}$/, 1, 'date_entered gives six digits' );
