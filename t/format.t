BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Format;
$loaded = 1;
print "ok 1\n";

#
# ensure &startint returns a reasonable value
#

# try right formatting
if ("  foo" eq fmtstr('','foo','R5')) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}

# try left formatting
if ("foo  " eq fmtstr('','foo','L5')) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}

# try centering with even spacing
if (" foo " eq fmtstr('','foo','C5')) {
    print "ok 4\n";
} else {
    print "not ok 4\n";
}

# try centering with uneven spacing
if ("foo " eq fmtstr('','foo','C4')) {
    print "ok 5\n";
} else {
    print "not ok 5\n";
}
