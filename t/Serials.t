#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

use_ok('C4::Serials');
my $supplierlist=eval{GetSuppliersWithLateIssues()};
ok(length($@)==0,"No SQL problem in GetSuppliersWithLateIssues");
done_testing();
