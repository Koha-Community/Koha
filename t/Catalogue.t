# $Id$

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Catalogue;
$loaded = 1;
print "ok 1\n";



# getAuthor() test

$bibid=1234;

my $author=getAuthor(1234);

if ($author eq 'Farley Mowatt') {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}

# getTitle() test

$bibid=1234;

my $title=getTitle(1234);

if ($title eq '') {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}


# $Log$
# Revision 1.1  2002/05/31 22:17:12  tonnesen
# Skeleton test file for Catalogue.pm.  Fails miserably so far.  :)
#
