#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;
use C4::Context;

my $opacheader = C4::Context->preference('opacheader');
my $newopacheader = "newopacheader";

C4::Context->set_preference('OPACHEADER', $newopacheader);
ok(C4::Context->preference('opacheader') eq $newopacheader);

C4::Context->set_preference('opacheader', $opacheader);
ok(C4::Context->preference('OPACHEADER') eq $opacheader);
