#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Test::More tests => 3;
use Test::MockModule;

BEGIN {
    use_ok('C4::Context');
}

my $oConnection = C4::Context->Zconn('biblioserver', 0);
isnt($oConnection->option('async'), 1, "ZOOM connection is synchronous");
$oConnection = C4::Context->Zconn('biblioserver', 1);
is($oConnection->option('async'), 1, "ZOOM connection is asynchronous");
