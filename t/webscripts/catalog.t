BEGIN { 
    unless ($ENV{'nonproductionserver'}) {
	print "1..0 # Skipped: environment variable 'nonproductionserver' not set\n";
	exit;
    }
    
    $| = 1; print "1..30\n";
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

my $test='Search - no parameters';
my $script="$intranetdir/cgi-bin/search.pl";
contains($script, $test, ['kohaadmin']);

$test='Keyword search - bear';
$script="$intranetdir/cgi-bin/search.pl keyword=bear";
contains($script, $test, [8, 435, 225]);

$test='Title search - bear';
$script="$intranetdir/cgi-bin/search.pl title=bear";
contains($script, $test, [225, 290, 8, 470]);

$test='Author search - Thompson';
$script="$intranetdir/cgi-bin/search.pl author=thompson";
contains($script, $test, [200,164]);

$test='Author search - Johnson, Edna';
$script="$intranetdir/cgi-bin/search.pl author=Johnson,%20Edna";
contains($script, $test, [276]);


$test='Subject search - bear';
$script="$intranetdir/cgi-bin/search.pl subject=bear";
contains($script, $test, ['subjectitems=BEARS-BLACK', 'subjectitems=GRIZZLY%20BEARS']);

$test='Subjectitem search - BEARS-BLACK';
$script="$intranetdir/cgi-bin/search.pl subjectitems=BEARS-BLACK";
contains($script, $test, ['Encounters With Black Bears and Grizzly Bears', 225]);

$test='Dewey search - 599';
$script="$intranetdir/cgi-bin/search.pl dewey=599";
contains($script, $test, [70,208]);

$test='Illustrator search - blades';
$script="$intranetdir/cgi-bin/search.pl illustrator=blades";
contains($script, $test, [270]);

$test='Barcode search - T120';
$script="$intranetdir/cgi-bin/search.pl 'itemnumber=T120'";
contains($script, $test, [133, 'Floating Schools and Frozen Inkwells']);


$test='Detail - biblio #270';
$script="$intranetdir/cgi-bin/detail.pl bib=270";
contains($script, $test, ['Back to the cabin', 'Main Library']);


$test='Detail - biblio #164';
$script="$intranetdir/cgi-bin/detail.pl bib=164";
contains($script, $test, ['Draw-And-Tell', 'T424', 'T427', 'T436']);

$test='More Detail - biblio #164, biblioitem #164';
$script="$intranetdir/cgi-bin/moredetail.pl 'bib=164&bi=164'";
contains($script, $test, ['Draw-And-Tell', 'Junior Fiction', 'T148', '1550370324']);

$test='Modify Biblio - biblio #163';
$script="$intranetdir/cgi-bin/modbib.pl 'bibnum=163&submit.x=modify'";
contains($script, $test, ['name=Author value="Wellikoff, Alan"', 'name=Title value="The Historical Supply Catalogue"']);


# Add subject headings for #163 to catalogueentry table

$sth=$dbh->prepare("select * from catalogueentry where entrytype='s' and catalogueentry=?");
$sth->execute('UNITED STATES-MANUFACTURERS-CATALOGUE');
unless ($sth->rows) {
    $sth=$dbh->prepare("insert into catalogueentry (entrytype,catalogueentry) values ('s', ?)");
    $sth->execute('UNITED STATES-MANUFACTURERS-CATALOGUE');
}
$sth=$dbh->prepare("select * from catalogueentry where entrytype='s' and catalogueentry=?");
$sth->execute('CATALOGUES-HISTORICAL SUPPLIES');
unless ($sth->rows) {
    $sth=$dbh->prepare("insert into catalogueentry (entrytype,catalogueentry) values ('s', ?)");
    $sth->execute('CATALOGUES-HISTORICAL SUPPLIES');
}

$test='Modify Biblio change title to "Testing" - biblio #163';
$script="$intranetdir/cgi-bin/updatebiblio.pl 'Author=Wellikoff%2C+Alan&Title=Testing&Subject=UNITED+STATES-MANUFACTURERS-CATALOGUE%7CCATALOGUES-HISTORICAL+SUPPLIES&Copyright=&Series=&Additional=&Subtitle=&Unititle=&Notes=&Serial=&Analytic=&Analytic=&bibnum=163&bibitemnum=163'";
contains($script, $test, ['location: detail.pl', 'bib=163']);

$sth=$dbh->prepare("select title from biblio where biblionumber=163");
$sth->execute();
my ($title) = $sth->fetchrow;
if ($title eq 'Testing') {
    print "ok ".$testnumber++." title is now 'Testing'\n";
} else {
    print "not ok ".$testnumber++." title is now $title\n";
}


$test='Modify Biblio change title back to "The Historical Supply Catalogue" - biblio #163';
$script="$intranetdir/cgi-bin/updatebiblio.pl 'Author=Wellikoff%2C+Alan&Title=The+Historical+Supply+Catalogue&Subject=UNITED+STATES-MANUFACTURERS-CATALOGUE%7CCATALOGUES-HISTORICAL+SUPPLIES&Copyright=&Series=&Additional=&Subtitle=&Unititle=&Notes=&Serial=&Analytic=&Analytic=&bibnum=163&bibitemnum=163'";
contains($script, $test, ['location: detail.pl', 'bib=163']);

$sth=$dbh->prepare("select title from biblio where biblionumber=163");
$sth->execute();
my ($title) = $sth->fetchrow;
if ($title eq 'The Historical Supply Catalogue') {
    print "ok ".$testnumber++." title is now 'The Historical Supply Catalogue'\n";
} else {
    print "not ok ".$testnumber++." title is now $title\n";
}

$script="$intranetdir/cgi-bin/delbiblio.pl 'biblio=163'";
contains($script, $test, ['delete them before deleting this biblio']);

$sth=$dbh->prepare("select biblionumber from biblio where biblionumber=163");
$sth->execute;
if ($sth->rows) {
    print "ok ".$testnumber++." biblio 163 was not deleted.\n";
} else {
    print "not ok ".$testnumber++." biblio 163 is gone!\n";
}

$test='Delete Biblio with no items - biblio #57';
$script="$intranetdir/cgi-bin/delbiblio.pl 'biblio=57'";
contains($script, $test, ['delete the biblio and all of its subgroups']);

$test='Delete Biblio with no items, confirmed - biblio #57';
$script="$intranetdir/cgi-bin/delbiblio.pl 'biblio=57&confirmed=1'";
contains($script, $test, ['location:', 'catalogue-home.pl']);

$sth=$dbh->prepare("select * from biblio where biblionumber=57");
$sth->execute;
if ($sth->rows) {
    print "not ok ".$testnumber++." biblio 57 is still in biblio table!\n";
} else {
    print "ok ".$testnumber++." biblio 57 was deleted.\n";
}

$sth=$dbh->prepare("select biblionumber from deletedbiblio where biblionumber=57");
$sth->execute;
if ($sth->rows) {
    print "ok ".$testnumber++." biblio 57 is in deletedbiblio table.\n";
} else {
    print "not ok ".$testnumber++." biblio 57 is not in deletedbiblio table!\n";
}

my $query="select * from deletedbiblio where biblionumber=57";
$sth=$dbh->prepare($query);
$sth->execute;
if (my @data=$sth->fetchrow_array) {
    $sth->finish;
    $query="Insert into biblio values (";
    foreach my $temp (@data){
	$temp=~ s/\'/\\\'/g;
	$query.=$dbh->quote($temp).",";
    }
    $query=~ s/\,$/\)/;
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query = "delete from deletedbiblio where biblionumber=57";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
}

$test='Modify biblioitem (group) - biblioitem #331';
$script="$intranetdir/cgi-bin/modbibitem.pl 'bibitem=331&biblio=331&submit.x=62&submit=modify'";
contains($script, $test, ['Dog stories', 'Herriot, James', 'T291', 331]);

$test='Modify biblioitem (group) change itemtype to JNF - biblioitem #331';
$script="$intranetdir/cgi-bin/updatebibitem.pl 'existinggroup=331&existing=NO&Item=JNF&Class=HER&Publisher=&Place=&ISBN=0330296957&Publication=0&Pages=20p.+Illus.&Illustrations=&Volume=&Notes=&Size=&bibnum=331&bibitemnum=331&check_group_T291=on&submit.x=103&submit.y=30'";
contains($script, $test, ['location:', 'moredetail.pl', 331]);

$sth=$dbh->prepare("select itemtype from biblioitems where biblioitemnumber=331");
$sth->execute();
my ($itemtype) = $sth->fetchrow;
if ($itemtype eq 'JNF') {
    print "ok ".$testnumber++." itemtype is now JNF\n";
} else {
    print "not ok ".$testnumber++." itemtype is now $itemtype\n";
}

$test='Modify biblioitem (group) change itemtype back to JF - biblioitem #331';
$script="$intranetdir/cgi-bin/updatebibitem.pl 'existinggroup=331&existing=NO&Item=JF&Class=HER&Publisher=&Place=&ISBN=0330296957&Publication=0&Pages=20p.+Illus.&Illustrations=&Volume=&Notes=&Size=&bibnum=331&bibitemnum=331&check_group_T291=on&submit.x=103&submit.y=30'";
contains($script, $test, ['location:', 'moredetail.pl', 331]);


$sth=$dbh->prepare("select itemtype from biblioitems where biblioitemnumber=331");
$sth->execute();
my ($itemtype) = $sth->fetchrow;
if ($itemtype eq 'JF') {
    print "ok ".$testnumber++." itemtype is now JF\n";
} else {
    print "not ok ".$testnumber++." itemtype is now $itemtype\n";
}



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
	    warn "\nTestnumber $testnumber ($test) failed.  Couldn't find '$string' in output.\n";
	    return;
	}
    }
    print "ok ".$testnumber++." $test\n";
}
