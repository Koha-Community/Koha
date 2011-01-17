#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
        use_ok('C4::BackgroundJob');
}

#my ($sessionID, $job_name, $job_invoker, $num_work_units) = @_;
my $background;
ok ($background=C4::BackgroundJob->new);
ok ($background->id);

$background->name("George");
is ($background->name, "George", "testing name");

$background->invoker("enjoys");
is ($background->invoker, "enjoys", "testing invoker");

$background->progress("testing");
is ($background->progress, "testing", "testing progress");

ok ($background->status);

$background->size("56");
is ($background->size, "56", "testing size");

