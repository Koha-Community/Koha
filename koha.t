BEGIN { $| = 1; print "1..6\n"; }
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

#
# Check that &fixEthnicity returns correct values
#
if ('Maori' eq fixEthnicity('maori') {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}
if ('European/Pakeha' eq fixEthnicity('european') {
    print "ok 4\n";
} else {
    print "not ok 4\n";
}
if ('Pacific Islander' eq fixEthnicity('pi') {
    print "ok 5\n";
} else {
    print "not ok 5\n";
}
if ('Asian' eq fixEthnicity('asian') {
    print "ok 6\n";
} else {
    print "not ok 6\n";
}
