#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 3;

BEGIN {
    use_ok('Koha::Z3950Responder');
}

my $zR = Koha::Z3950Responder->new( {} );

my $args = { PEER_NAME => 'PEER' };
$zR->init_handler($args);
is( $args->{IMP_NAME}, 'Koha', 'Server returns basic info' );
