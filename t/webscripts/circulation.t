BEGIN { $| = 1; print "1..7\n";
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

my $test='Circulation - circulation.pl no parameters';
my $script="$intranetdir/cgi-bin/circ/circulation.pl";
contains($script, $test, ['Enter borrower card number']);

my $test='Circulation - findborrowers like "lib"';
my $script="$intranetdir/cgi-bin/circ/circulation.pl 'findborrower=lib'";
contains($script, $test, ['Librarian', 'Generic', 'Enter Book Barcode']);

my $test='Circulation - issue item "T008" to "librarian"';
my $script="$intranetdir/cgi-bin/circ/circulation.pl 'barcode=T008&borrnumber=1&branch=MAIN&printer=lp&print=maybe&submit.x=Issue'";
contains($script, $test, ['Librarian', 'Generic', 'Enter Book Barcode']);

my $test='Circulation - returns.pl no parameters';
my $script="$intranetdir/cgi-bin/circ/returns.pl";
contains($script, $test, ['Circulation: Returns', 'Enter Book Barcode']);

my $test='Circulation - return item "T008" ';
my $script="$intranetdir/cgi-bin/circ/returns.pl 'barcode=T008'";
contains($script, $test, ['Librarian', 'Generic', 'Enter Book Barcode', 'The man in bearskin']);

my $test='Circulation - return unissued item "T009" ';
my $script="$intranetdir/cgi-bin/circ/returns.pl 'barcode=T008'";
contains($script, $test, ['Enter Book Barcode', 'Not on loan.']);




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
