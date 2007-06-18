BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Koha;
$loaded = 1;
print "ok 1\n";

#
# test that &slashifyDate returns correct (non-US) date
#
$date = "01/01/2002";
$newdate = &slashifyDate("2002-01-01");

if ($date eq $newdate) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}


