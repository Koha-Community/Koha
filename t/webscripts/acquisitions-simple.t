BEGIN { 
    unless ($ENV{'nonproductionserver'}) {
	print "1..0 # Skipped: environment variable 'nonproductionserver' not set\n";
	exit;
    }

    $| = 1; print "1..9\n";
    $::intranetdir=`grep intranetdir /etc/koha.conf`;
    chomp $::intranetdir;
    $::intranetdir=~s/\s*intranetdir\s*=\s*//i;
}

END {print "not ok 1 test script load\n" unless $loaded;}

use lib $::intranetdir."/modules";
$ENV{PERLLIB}=$::intranetdir."/modules";

use C4::Context;
$loaded = 1;
print "ok 1 Test script load\n";

my $dbh=C4::Context->dbh();
my $sth;

my $debug=$ARGV[0];

my $intranetdir=C4::Context->config('intranetdir');
my $user=C4::Context->config('user');
$ENV{REMOTE_USER}=$user;

my $testnumber=2;

my $test='Acquisitions/Simple - addbooks.pl no parameters';
my $script="$intranetdir/cgi-bin/acqui.simple/addbooks.pl";
contains($script, $test, ['input name=isbn']);

my $test='Acquisitions/Simple - addbooks.pl ISBN=0920541968';
my $script="$intranetdir/cgi-bin/acqui.simple/addbooks.pl 'isbn=0920541968'";
contains($script, $test, ['input name=title', 'input name=author', 'input name=subtitle']);

my $test='Acquisitions/Simple - addbooks.pl ISBN=0920541968 Section One';
my $script="$intranetdir/cgi-bin/acqui.simple/addbooks.pl 'isbn=0920541968&checkforbiblio=1&title=On+the+Move&subtitle=Teaching+the+Learners+Way+In+Grades+4-7&author=Forester,+Anne+D.&copyrightdate=1991&notes=Testing+Book+entered+by+Koha+test+script'";
contains($script, $test, ['input name=publishercode', 'input name=publicationyear', 'input name=place', 'input name=illus', 'name=biblionumber value=501']);

$sth=$dbh->prepare("select title,author from biblio where biblionumber=501");
$sth->execute;
my ($title, $author) = $sth->fetchrow;
$sth=$dbh->prepare("select subtitle from bibliosubtitle where biblionumber=501");
$sth->execute;
my ($subtitle) = $sth->fetchrow;
if ($title eq 'On the Move' and $author eq 'Forester, Anne D.' && $subtitle eq 'Teaching the Learners Way In Grades 4-7') {
    print "ok ".$testnumber++." biblio added correctly.\n";
} else {
    print "not ok ".$testnumber++." biblio not added correctly.\n";
}

my $test='Acquisitions/Simple - addbooks.pl ISBN=0920541968 Section Two';
my $script="$intranetdir/cgi-bin/acqui.simple/addbooks.pl 'isbn=0920541968&biblionumber=501&newbiblioitem=1&publishercode=Stratton+and+Co.&publicationyear=1997&place=New+York&illus=Margaret+Reinhard&additionalauthors=Margaret+Reinhard&subjectheadings=&itemtype=NF&dewey=372.6&subclass=FOR&issn=&lccn=&volume=&pages=335p.&size=10in.&notes=Test+biblioitem+added+by+Koha+test+scripts'";
contains($script, $test, ['name=newitem value=1', 'name=biblionumber value=501', 'name=biblioitemnumber value=501', 'input name=barcode']);

$sth=$dbh->prepare("select isbn,publishercode,publicationyear,place,illus,itemtype,dewey from biblioitems where biblioitemnumber=501");
$sth->execute;
my ($isbn,$publishercode,$publicationyear,$place,$illus,$itemtype,$dewey) = $sth->fetchrow;
if (
    $isbn eq '0920541968' and
    $publishercode eq 'Stratton and Co.' and
    $publicationyear == 1997 and
    $place eq "New York" and
    $illus eq "Margaret Reinhard" and
    $itemtype eq 'NF' and
    $dewey == 372.6
    ) {
    print "ok ".$testnumber++." biblioitem added correctly.\n";
} else {
    print "not ok ".$testnumber++." biblioitem not added correctly. $isbn $publishercode $publicationyear $place $illus $itemtype $dewey\n";
}

my $test='Acquisitions/Simple - addbooks.pl ISBN=0920541968 Section Three';
my $script="$intranetdir/cgi-bin/acqui.simple/addbooks.pl 'newitem=1&biblionumber=501&biblioitemnumber=501&barcode=T777&homebranch=MAIN&replacementprice=17.99&notes=Test+item+added+by+Koha+test+harness.'";
contains($script, $test, ['input name=isbn']);

$sth=$dbh->prepare("select barcode,homebranch,replacementprice,itemnotes from items where biblioitemnumber=501");
$sth->execute;
my ($barcode,$homebranch,$replacementprice,$notes) = $sth->fetchrow;
if (
    $barcode eq 'T777' and
    $homebranch eq 'MAIN' and 
    $replacementprice == 17.99 and
    $notes eq 'Test item added by Koha test harness.'
    ) {
    print "ok ".$testnumber++." item added correctly.\n";
} else {
    print "not ok ".$testnumber++." item not added correctly. $barcode, $homebranch, $replacementprice, $notes\n";
}

$sth=$dbh->do("delete from items where biblionumber=501");
$sth=$dbh->do("delete from biblioitems where biblionumber=501");
$sth=$dbh->do("delete from bibliosubtitle where biblionumber=501");
$sth=$dbh->do("delete from bibliosubject where biblionumber=501");
$sth=$dbh->do("delete from additionalauthors where biblionumber=501");
$sth=$dbh->do("delete from biblio where biblionumber=501");



sub contains {
    my $script = shift;
    my $test = shift;
    my $contains = shift;
    my $result=`perl $script`;
    if ($debug) {
	open O, ">test-".$testnumber.".html";
	print O $result;
	close O;
    }
    foreach my $string (@$contains) {
	unless ($result=~/$string/) {
	    print "not ok ".$testnumber++." $test (couldn't find '$string')\n";
	    return;
	}
    }
    print "ok ".$testnumber++." $test\n";
}
