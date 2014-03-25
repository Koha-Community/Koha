#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Test::More tests => 1;
use Test::MockModule;

BEGIN {
    use_ok('C4::Context');
}
