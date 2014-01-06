#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 10;

BEGIN {
        use_ok('C4::Output::JSONStream');
}

my $json = new C4::Output::JSONStream;
is($json->output,'{}',"Making sure JSON output is blank just after its created.");
$json->param( issues => [ 'yes!', 'please', 'no' ] );
is($json->output,'{"issues":["yes!","please","no"]}',"Making sure JSON output has added what we told it to.");
$json->param( stuff => ['realia'] );
like($json->output,'/"stuff":\["realia"\]/',"Making sure JSON output has added more params correctly.");
like($json->output,'/"issues":\["yes!","please","no"\]/',"Making sure existing elements remain in JSON output");
$json->param( stuff => ['fun','love'] );
like($json->output,'/"stuff":\["fun","love"\]/',"Making sure JSON output can overwrite params.");
like($json->output,'/"issues":\["yes!","please","no"\]/',"Making non overwitten elements remain in JSON output");

eval{$json->param( die )};
ok($@,'Dies');

eval{$json->param( die => ['yes','sure','now'])};
ok(!$@,'Does not die.');
eval{$json->param( die => ['yes','sure','now'], die2 =>)};
ok($@,'Dies.');
