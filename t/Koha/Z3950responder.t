#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 8;

BEGIN {
    use_ok('Koha::Z3950Responder');
}

my $zR = Koha::Z3950Responder->new({});

my $args={ PEER_NAME => 'PEER'};
$zR->init_handler($args);
is ( $args->{IMP_NAME}, 'Koha',"Server returns basic info");
$args->{DATABASES} = ['biblios'];
$args->{QUERY} = 'biblios';
$args->{SETNAME} = 'biblios';
$args->{START} = 0;
$args->{OFFSET} = 0;
$args->{NUMBER} = 42;
$zR->search_handler( $args );
is ( $args->{ERR_CODE}, 2, "We didn't start server , should fail");
is ( $args->{ERR_STR}, 'Cannot connect to upstream server', "We didn't start server, should fail because it cannot connect");
$zR->present_handler( $args );
is ( $args->{ERR_CODE}, 30, "There is no handler as we aren't connected");
is ( $args->{ERR_STR}, 'No such resultset', "We don't have a handler, should fail because we don't");
my $arg_check = ( $args );
$zR->fetch_handler( $args );
is_deeply( $args, $arg_check, "nothing should change");
$zR->close_handler( $args );
is_deeply( $args, $arg_check, "nothing should change");
