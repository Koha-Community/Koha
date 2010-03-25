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
use C4::Debug;

my $baseurl= $ARGV[0] || "http://am123/cgi-bin/koha/";
my $max_tries = 200;
my $concurrency = 30;
my $user = $ARGV[1] ||'hdl';
my $password = $ARGV[2] || 'hdl';

# Authenticate via our handy dandy RESTful services
# and grab a cookie
my $ua = LWP::UserAgent->new();
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
print "Benchmarking with $max_tries occurences of each operation and $concurrency concurrent sessions \n";
print "Load testing opac client main page";
for (my $i=1;$i<=$max_tries;$i++) {
    push @mainpage,"$baseurl/opac-main.pl";
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
print "Load testing catalog detail page";
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_biblionumber = int(rand($biblionumber_max)+1);
    push @biblios,"$baseurl/opac-detail.pl?biblionumber=$rand_biblionumber";
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
print "Load testing search page";
for (my $i=1;$i<=$max_tries;$i++) {
#     print "$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber\n";
    push @borrowers,"$baseurl/opac-search.pl?idx=ti&q=Code";
    push @borrowers,"$baseurl/opac-search.pl?idx=au&q=Jean";
    push @borrowers,"$baseurl/opac-search.pl?idx=su&q=Droit";
}
my $run2 = HTTPD::Bench::ApacheBench::Run->new
    ({ urls => \@borrowers,
    });
$b2->add_run($run2);
$b->add_run($run2);

# send HTTP request sequences to server and time responses
$ro = $b2->execute;
# calculate hits/sec
print ("\t".$b2->total_time."ms\t".(1000*$b2->total_requests/$b2->total_time)." searches/sec\n");

print "Load testing all transactions at once";
$ro = $b->execute;
print ("\t".$b->total_time."ms\t".(1000*$b->total_requests/$b->total_time)." operations/sec\n");
