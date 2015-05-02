#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 14;
use Test::Warn;

BEGIN {
        use_ok('C4::Search::PazPar2');
}

my $obj = C4::Search::PazPar2->new();
ok ($obj, "testing new works");

my $result;
warning_like { $result = $obj->init(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, "1", "testing init returns '1' when given no arguments");

warning_like { $result = $obj->search(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, "1", "testing search returns '1' when given no arguments");

warning_like { $result = $obj->stat(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, undef, "testing stat returns undef when given no arguments");

warning_like { $result = $obj->show(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, undef, "testing show returns undef when given no arguments");

warning_like { $result = $obj->record(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, undef, "testing record returns undef when given no arguments");

warning_like { $result = $obj->termlist(); }
    qr/400 URL must be absolute at .*C4\/Search\/PazPar2.pm/,
    "Expected relative URL warning";
is ($result, undef, "testing termlist returns undef when given no arguments");
