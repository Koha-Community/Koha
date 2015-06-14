#!/usr/bin/perl
# This script implements a basic benchmarking and regression testing
# utility for Koha

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use HTTPD::Bench::ApacheBench;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Cookies;
use C4::Context;

my $baseurl= C4::Context->preference("staffClientBaseURL")."/cgi-bin/koha/";
my $max_tries = 200;
my $concurrency = 10;
my $debug;
my $user = 'kados';
my $password = 'kados';

# Authenticate via our handy dandy RESTful services
# and grab a cookie
my $ua = LWP::UserAgent->new();
my $cookie_jar = HTTP::Cookies->new();
my $cookie;
$ua->cookie_jar($cookie_jar);
my $resp = $ua->post( "$baseurl"."/svc/authentication" , {userid =>$user, password => $password} );
if( $resp->is_success ) {
    $cookie_jar->extract_cookies( $resp );
    $cookie = $cookie_jar->as_string;
    print "Authentication successful\n";
    print "Auth:\n $resp->content" if $debug;
}
# remove some unnecessary garbage from the cookie
$cookie =~ s/ path_spec; discard; version=0//;
$cookie =~ s/Set-Cookie3: //;

# Get some data to work with
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
print "Koha circulation benchmarking utility\n";
print "--------------\n";
print "Benchmarking with $max_tries occurrences of each operation and $concurrency concurrent sessions \n";
print "Load testing staff client dashboard page";
for (my $i=1;$i<=$max_tries;$i++) {
    push @mainpage,"$baseurl/mainpage.pl";
}
my $run0 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@mainpage,
       cookies => [$cookie],
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
print "Load testing catalog detail page";
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_biblionumber = int(rand($biblionumber_max)+1);
    push @biblios,"$baseurl/catalogue/detail.pl?biblionumber=$rand_biblionumber";
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
print "Load testing patron detail page";
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_borrowernumber = int(rand($borrowernumber_max)+1);
#     print "$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber\n";
    push @borrowers,"$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber";
}
my $run2 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@borrowers,
       cookies => [$cookie],
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
print "Load testing circulation transaction (checkouts)";
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
    }
    print "borrowernumber=$rand_borrowernumber&barcode=$rand_barcode\n";
    push @issues,"$baseurl/circ/circulation.pl?borrowernumber=$rand_borrowernumber&barcode=$rand_barcode&issueconfirmed=1";
    push @returns,"$baseurl/circ/returns.pl?barcode=$rand_barcode";
}
my $run3 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@issues,
       cookies => [$cookie],
    });
$b3->add_run($run3);
$b->add_run($run3);

# send HTTP request sequences to server and time responses
$ro = $b3->execute;
# calculate hits/sec
print ("\t".$b3->total_time."ms\t".(1000*$b3->total_requests/$b3->total_time)." checkouts/sec\n");

print "Load testing circulation transaction (checkins)";
my $run4 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@returns,
       cookies => [$cookie],
    });
$b4->add_run($run4);
$b->add_run($run4);

# send HTTP request sequences to server and time responses
$ro = $b4->execute;
# calculate hits/sec
print ("\t".$b4->total_time."ms\t".(1000*$b4->total_requests/$b4->total_time)." checkins/sec\n");

print "Load testing all transactions at once";
$ro = $b->execute;
print ("\t".$b->total_time."ms\t".(1000*$b->total_requests/$b->total_time)." operations/sec\n");
