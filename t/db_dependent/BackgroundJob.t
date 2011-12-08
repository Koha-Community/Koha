#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
use C4::Auth;
use CGI;
use Test::More tests => 10;

BEGIN {
        use_ok('C4::BackgroundJob');
}
my $query = new CGI;
my ($userid, $cookie, $sessionID) = &checkauth($query, 1);
#my ($sessionID, $job_name, $job_invoker, $num_work_units) = @_;
my $background;
diag $sessionID;
ok ($background=C4::BackgroundJob->new($sessionID));
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

$background->finish("finished");
is ($background->status,'completed', "testing finished");

ok ($background->results); # Will return undef unless finished