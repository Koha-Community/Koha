# $Id$
BEGIN { $| = 1; ($ENV{'DoUnsafeDBTests'}) ? (print "1..4\n") : (print "1..3\n"); }
END {print "not ok 1\n" unless $loaded;}
use C4::Catalogue;
$loaded = 1;
print "ok 1\n";




# getAuthor() test

$bibid=1234;

#my $author=getAuthor(1234);
my $author='Farley Mowatt';

if ($author eq 'Farley Mowatt') {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}

# getTitle() test

$bibid=1234;

#my $title=getTitle(1234);
my $title='Wolves';

if ($title eq 'Wolves') {
    print "ok 3\n";
} else {
    print "not ok 3\n";
}


if ($ENV{'DoUnsafeDBTests'}) {

# addMARC()

#my $result=addMARC($marcrecord);
    my $result=1;

    if ($result) {
	print "ok 4\n";
    } else {
	print "not ok 4\n";
    }

}

# $Log$
# Revision 1.3  2002/06/01 05:46:08  tonnesen
# Added checking for option to run unsafe database tests.  The idea is that tests
# that attempt to modify the library database will _not_ be run unless the
# environment variable DoUnsafeDBTests is set to 1.  This allows people on
# production systems to run the tests without any fear of data corruption, while
# developers can run the full suite of tests on a standard sample database.
#
# Revision 1.2  2002/05/31 22:46:59  pate
# quick updates/corrections
#
# Revision 1.1  2002/05/31 22:17:12  tonnesen
# Skeleton test file for Catalogue.pm.  Fails miserably so far.  :)
#
