BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Output;
$loaded = 1;
print "ok 1\n";

#
# ensure &startpage returns correct value
#
if ("<html>\n" eq startpage()) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}

#
# Check that &gotopage returns proper value
#
if ("<META HTTP-EQUIV=Refresh CONTENT=\"0;URL=http:foo\">" eq gotopage('foo')) {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}

#
# skipping &startmenu for now
#

#
# skipping &endmenu for now

#
# ensure &mktablehdr returns a proper value
#

if ("<table border=0 cellspacing=0 cellpadding=5>\n" eq mktablehdr()) {
    print "ok 4\n";
} else {
    print "not ok 4\n";
}

#
# ensure &mktablerow returns a proper value
#
# 1 row, no background image
if ("<tr valign=top bgcolor=red><td>text</td></tr>\n" eq
    mktablerow(1,'red','text','')) {
    print "ok 5\n";
} else { 
    print "not ok 5\n";
}
# 1 row, background image
if ("<tr valign=top bgcolor=red><td background=\"foo.jpg\">text</td></tr>\n" eq
    mktablerow(1,'red','text','foo.jpg')) {
    print "ok 6\n";
} else {
    print "not ok 6\n";
}

