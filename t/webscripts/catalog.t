BEGIN { $| = 1; print "1..6\n";
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


$test='Subject search - bear';
$script="$intranetdir/cgi-bin/search.pl subject=bear";
contains($script, $test, ['subjectitems=BEARS-BLACK', 'subjectitems=GRIZZLY%20BEARS']);

$test='Dewey search - 599';
$script="$intranetdir/cgi-bin/search.pl dewey=599";
contains($script, $test, [70,208]);

$test='Illustrator search - blades';
$script="$intranetdir/cgi-bin/search.pl illustrator=blades";
contains($script, $test, [270]);


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


$test='Modify Biblio change title to "Testing" - biblio #163';
$script="$intranetdir/cgi-bin/updatebiblio.pl 'Author=Wellikoff%2C+Alan&Title=Testing&Subject=UNITED+STATES-MANUFACTURERS-CATALOGUE%7CCATALOGUES-HISTORICAL+SUPPLIES&Copyright=&Series=&Additional=&Subtitle=&Unititle=&Notes=&Serial=&Analytic=&Analytic=&bibnum=163&bibitemnum=163'";
contains($script, $test, ['location: detail.pl', 'bib=163']);

$test='Modify Biblio change title back to "The Historical Supply Catalogue" - biblio #163';
$script="$intranetdir/cgi-bin/updatebiblio.pl 'Author=Wellikoff%2C+Alan&Title=The+Historical+Supply+Catalogue&Subject=UNITED+STATES-MANUFACTURERS-CATALOGUE%7CCATALOGUES-HISTORICAL+SUPPLIES&Copyright=&Series=&Additional=&Subtitle=&Unititle=&Notes=&Serial=&Analytic=&Analytic=&bibnum=163&bibitemnum=163'";
contains($script, $test, ['location: detail.pl', 'bib=163']);





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
	    print "not ok ".$testnumber++." $test $string\n";
	    return;
	}
    }
    print "ok ".$testnumber++." $test\n";
}
