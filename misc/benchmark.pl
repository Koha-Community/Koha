#!/usr/bin/perl
# This is an example script for how to benchmark various 
# parts of your Koha system. It's useful for measuring the 
# impact of mod_perl on performance.
use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}
use HTTPD::Bench::ApacheBench;
use C4::Context;

# 1st, find some max values
my $dbh=C4::Context->dbh();
my $sth = $dbh->prepare("select max(borrowernumber) from borrowers");
$sth->execute;
my ($borrowernumber_max) = $sth->fetchrow;

$sth = $dbh->prepare("select max(biblionumber) from biblio");
$sth->execute;
my ($biblionumber_max) = $sth->fetchrow;

$sth = $dbh->prepare("select max(itemnumber) from items");
$sth->execute;
my ($itemnumber_max) = $sth->fetchrow;

my $baseurl= C4::Context->preference("staffClientBaseURL")."/cgi-bin/koha/";
my $max_tries = 200;
my $concurrency = 5;

$|=1;
#
# the global benchmark we do at the end...
#
my $b = HTTPD::Bench::ApacheBench->new;
$b->concurrency( $concurrency );
#
# mainpage : (very) low RDBMS dependency
#
my $b0 = HTTPD::Bench::ApacheBench->new;
$b0->concurrency( $concurrency );

my @mainpage;
print "--------------\n";
print "Koha benchmark\n";
print "--------------\n";
print "benchmarking with $max_tries occurences of each operation\n";
print "mainpage (low RDBMS dependency) ";
for (my $i=1;$i<=$max_tries;$i++) {
    push @mainpage,"$baseurl/mainpage.pl";
}
my $run0 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@mainpage,
    });
$b0->add_run($run0);
$b->add_run($run0);

# send HTTP request sequences to server and time responses
my $ro = $b0->execute;
# calculate hits/sec
print ("\t".$b0->total_time."ms\t".(1000*$b0->total_requests/$b0->total_time)." pages/sec\n");
print "ALERT : ".$b0->total_responses_failed." failures\n" if $b0->total_responses_failed;

#
# biblios
#
my $b1 = HTTPD::Bench::ApacheBench->new;
$b1->concurrency( $concurrency );

my @biblios;
print "biblio (MARC detail)";
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_biblionumber = int(rand($biblionumber_max)+1);
    push @biblios,"$baseurl/catalogue/MARCdetail.pl?biblionumber=$rand_biblionumber";
}
my $run1 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@biblios,
    });
$b1->add_run($run1);
$b->add_run($run1);

# send HTTP request sequences to server and time responses
$ro = $b1->execute;
# calculate hits/sec
print ("\t".$b1->total_time."ms\t".(1000*$b1->total_requests/$b1->total_time)." biblios/sec\n");
print "ALERT : ".$b1->total_responses_failed." failures\n" if $b1->total_responses_failed;

#
# borrowers
#
my $b2 = HTTPD::Bench::ApacheBench->new;
$b2->concurrency( $concurrency );

my @borrowers;
print "borrower detail        ";
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_borrowernumber = int(rand($borrowernumber_max)+1);
#     print "$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber\n";
    push @borrowers,"$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber";
}
my $run2 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@borrowers,
    });
$b2->add_run($run2);
$b->add_run($run2);

# send HTTP request sequences to server and time responses
$ro = $b2->execute;
# calculate hits/sec
print ("\t".$b2->total_time."ms\t".(1000*$b2->total_requests/$b2->total_time)." borrowers/sec\n");


#
# issue (& then return) books
#
my $b3 = HTTPD::Bench::ApacheBench->new;
$b3->concurrency( $concurrency );
my $b4 = HTTPD::Bench::ApacheBench->new;
$b4->concurrency( $concurrency );

my @issues;
my @returns;
print "Issues detail          ";
$sth = $dbh->prepare("SELECT barcode FROM items WHERE itemnumber=?");
my $sth2 = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE borrowernumber=?");
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_borrowernumber;
    # check that the borrowernumber exist
    until ($rand_borrowernumber) {
        $rand_borrowernumber = int(rand($borrowernumber_max)+1);
        $sth2->execute($rand_borrowernumber);
        ($rand_borrowernumber) = $sth2->fetchrow;
    }
    # find a barcode & check it exists
    my $rand_barcode;
    until ($rand_barcode) {
        my $rand_itemnumber = int(rand($itemnumber_max)+1);
        $sth->execute($rand_itemnumber);
        ($rand_barcode) = $sth->fetchrow();
#         print "$baseurl/circ/circulation.pl?borrowernumber=$rand_borrowernumber&barcode=$rand_barcode&issueconfirmed=1&year=2010&month=01&day=01\n";
    }
    push @issues,"$baseurl/circ/circulation.pl?borrowernumber=$rand_borrowernumber&barcode=$rand_barcode&issueconfirmed=1";
    push @returns,"$baseurl/circ/returns.pl?barcode=$rand_barcode";
}
my $run3 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@issues,
    });
$b3->add_run($run3);
$b->add_run($run3);

# send HTTP request sequences to server and time responses
$ro = $b3->execute;
# calculate hits/sec
print ("\t".$b3->total_time."ms\t".(1000*$b3->total_requests/$b3->total_time)." issues/sec\n");

print "Returns detail         ";
my $run4 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@returns,
    });
$b4->add_run($run4);
$b->add_run($run4);

# send HTTP request sequences to server and time responses
$ro = $b4->execute;
# calculate hits/sec
print ("\t".$b4->total_time."ms\t".(1000*$b4->total_requests/$b4->total_time)." returns/sec\n");

print "Benchmarking everything";
$ro = $b->execute;
print ("\t".$b->total_time."ms\t".(1000*$b->total_requests/$b->total_time)." operations/sec\n");
