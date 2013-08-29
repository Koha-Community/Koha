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

use Getopt::Long;
use HTTPD::Bench::ApacheBench;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Cookies;
use C4::Context;
use C4::Debug;
use URI::Escape;

my ($help, $steps, $baseurl, $max_tries, $user, $password,$short_print);
GetOptions(
    'help'    => \$help,
    'steps:s'   => \$steps,
    'url:s' => \$baseurl,
    'user:s' => \$user,
    'password:s' => \$password,
    'maxtries:s' => \$max_tries,
    'short' => \$short_print,
);
my $concurrency = 30;
$max_tries=20 unless $max_tries;
# if steps not provided, run all tests
$steps='0123456789' unless $steps;

# if short is set, we will only give number for direct inclusion on the wiki
my $short_ms="|-\n|ON\n";
my $short_psec="|-\n|ON\n";

if ($help || !$baseurl || !$user || !$password) {
    print <<EOF
This script runs a benchmark of the staff interface. It benchmark 6 different pages:
\t1- the staff main page
\t2- the catalog detail page, with a random biblionumber
\t3- the catalog search page, using a term retrieved from one of the 10 first title/author in the database
\t4- the patron detail page, with a random borrowernumber
\t5- the patron search page, searching for "Jean"
\t6- the circulation itself, doing check-out and check-in of random items to random patrons

\t0 all those tests at once
parameters :
\thelp = this screen
\tsteps = which steps you want to run. 
\t\tDon't use it if you want to run all tests. enter 125 if you want to run tests 1, 2 and 5
\t\tThe "all those tests at once" is numbered 0,and will run all tests previously run.
\t\tIf you run only one step, it's useless to run the 0, you'll get the same result.
\turl = the URL or your staff interface
\tlogin = Koha login
\tpassword = Koha password
\tmaxtries = how many tries you want to do. Defaulted to 20

SAMPLE : ./benchmark_staff.pl --url=http://yourstaff.org/cgi-bin/koha/ --user=test --password=test --steps=12

EOF
;
exit;
}


# Authenticate via our handy dandy RESTful services
# and grab a cookie
my $ua = LWP::UserAgent->new();
my $cookie_jar = HTTP::Cookies->new();
my $cookie;
$ua->cookie_jar($cookie_jar);
my $resp = $ua->post( "$baseurl"."/svc/authentication" , {userid =>$user, password => $password} );
if( $resp->is_success and $resp->content =~ m|<status>ok</status>| ) {
    $cookie_jar->extract_cookies( $resp );
    $cookie = $cookie_jar->as_string;
    unless ($short_print) {
        print "Authentication successful\n";
        print "Auth:\n $resp->content" if $debug;
    }
} elsif ( $resp->is_success ) {
    die "Authentication failure: bad login/password";
} else {
    die "Authentication failure: \n\t" . $resp->status_line;
}

# remove some unnecessary garbage from the cookie
$cookie =~ s/ path_spec; discard; version=0//;
$cookie =~ s/Set-Cookie3: //;

# Get some data to work with
my $dbh=C4::Context->dbh();
# grab some borrowernumbers
my $sth = $dbh->prepare("select max(borrowernumber) from borrowers");
$sth->execute;
my ($borrowernumber_max) = $sth->fetchrow;
my @borrowers;
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_borrowernumber = int(rand($borrowernumber_max)+1);
    push @borrowers,"$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber";
}

# grab some biblionumbers
$sth = $dbh->prepare("select max(biblionumber) from biblio");
$sth->execute;
my ($biblionumber_max) = $sth->fetchrow;
my @biblios;
for (my $i=1;$i<=$max_tries;$i++) {
    my $rand_biblionumber = int(rand($biblionumber_max)+1);
    push @biblios,"$baseurl/catalogue/detail.pl?biblionumber=$rand_biblionumber";
}

# grab some title and author, for random search
$sth = $dbh->prepare ("SELECT title, author FROM biblio LIMIT 10");
$sth->execute;
my ($title,$author);
my @searchwords;
while (($title,$author)=$sth->fetchrow) {
    push @searchwords,split / /, $author;
    push @searchwords,split / /, $title;
}

$sth = $dbh->prepare("select max(itemnumber) from items");
$sth->execute;
# find the biggest itemnumber
my ($itemnumber_max) = $sth->fetchrow;

$|=1;
unless ($short_print) {
    print "--------------\n";
    print "Koha STAFF benchmarking utility\n";
    print "--------------\n";
    print "Benchmarking with $max_tries occurences of each operation and $concurrency concurrent sessions \n";
}
#
# the global benchmark we do at the end...
#
my $b = HTTPD::Bench::ApacheBench->new;
$b->concurrency( $concurrency );
my $ro;
#
# STEP 1: mainpage : (very) low RDBMS dependency
#
if ($steps=~ /1/) {
    my $b0 = HTTPD::Bench::ApacheBench->new;
    $b0->concurrency( $concurrency );    my @mainpage;
    unless ($short_print) {
        print "Step 1: staff client main page     ";
    }
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
    $ro = $b0->execute;
    # calculate hits/sec
    if ($short_print) {
        $short_ms.= "|".$b0->total_time."\n";
        $short_psec.="|".(int((1000*$b0->total_requests/$b0->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b0->total_time."ms\t".(int((1000*$b0->total_requests/$b0->total_time)*1000)/1000)." pages/sec\n");
        print "ALERT : ".$b0->total_responses_failed." failures\n" if $b0->total_responses_failed;
    }
} else {
    print "Skipping step 1\n";
}

#
# STEP 2: biblios
#
if ($steps=~ /2/) {
    my $b1 = HTTPD::Bench::ApacheBench->new;
    $b1->concurrency( $concurrency );

    unless ($short_print) {
        print "Step 2: catalog detail page        ";
    }
    my $run1 = HTTPD::Bench::ApacheBench::Run->new
        ({ urls => \@biblios,
           cookies => [$cookie],
        });
    $b1->add_run($run1);
    $b->add_run($run1);

    # send HTTP request sequences to server and time responses
    $ro = $b1->execute;
    # calculate hits/sec
    if ($short_print) {
        $short_ms.= "|".$b1->total_time."\n";
        $short_psec.="|".(int((1000*$b1->total_requests/$b1->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b1->total_time."ms\t".(int((1000*$b1->total_requests/$b1->total_time)*1000)/1000)." biblios/sec\n");
        print "ALERT : ".$b1->total_responses_failed." failures\n" if $b1->total_responses_failed;
    }
} else {
    print "Skipping step 2\n";
}
#
# STEP 3: search
#
if ($steps=~ /3/) {
    my $b1 = HTTPD::Bench::ApacheBench->new;
    $b1->concurrency( $concurrency );
    unless ($short_print) {
        print "Step 3: catalogue search               ";
    }
    my @searches;
    for (my $i=1;$i<=$max_tries;$i++) {
        push @searches,"$baseurl/catalogue/search.pl?q=".@searchwords[int(rand(scalar @searchwords))];
    }
    my $run1 = HTTPD::Bench::ApacheBench::Run->new
        ({ urls => \@searches,
           cookies => [$cookie],
        });
    $b1->add_run($run1);
    $b->add_run($run1);

    # send HTTP request sequences to server and time responses
    $ro = $b1->execute;
    # calculate hits/sec
    if ($short_print) {
        $short_ms.= "|".$b1->total_time."\n";
        $short_psec.="|".(int((1000*$b1->total_requests/$b1->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b1->total_time."ms\t".(int((1000*$b1->total_requests/$b1->total_time)*1000)/1000)." biblios/sec\n");
        print "ALERT : ".$b1->total_responses_failed." failures\n" if $b1->total_responses_failed;
    }
} else {
    print "Skipping step 3\n";
}
#
# STEP 4: borrowers
#
if ($steps=~ /4/) {
    my $b2 = HTTPD::Bench::ApacheBench->new;
    $b2->concurrency( $concurrency );
    unless ($short_print) {
        print "Step 4: patron detail page         ";
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
    if ($short_print) {
        $short_ms.= "|".$b2->total_time."\n";
        $short_psec.="|".(int((1000*$b2->total_requests/$b2->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b2->total_time."ms\t".(int((1000*$b2->total_requests/$b2->total_time)*1000)/1000)." borrowers/sec\n");
    }
} else {
    print "Skipping step 4\n";
}

#
# STEP 5: borrowers search
#
if ($steps=~ /5/) {
    my $b2 = HTTPD::Bench::ApacheBench->new;
    $b2->concurrency( $concurrency );
    unless ($short_print) {
        print "Step 5: patron search page             ";
    }
    for (my $i=1;$i<=$max_tries;$i++) {
    #     print "$baseurl/members/moremember.pl?borrowernumber=$rand_borrowernumber\n";
        push @borrowers,"$baseurl/members/member.pl?member=jean";
    }
    my $run2 = HTTPD::Bench::ApacheBench::Run->new
        ({ urls => \@borrowers,
           cookies => [$cookie],
        });
    $b2->add_run($run2);
    $b->add_run($run2);

    # send HTTP request sequences to server and time responses
    $ro = $b2->execute;
    if ($short_print) {
        $short_ms.= "|".$b2->total_time."\n";
        $short_psec.="|".(int((1000*$b2->total_requests/$b2->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b2->total_time."ms\t".(int((1000*$b2->total_requests/$b2->total_time)*1000)/1000)." borrowers/sec\n");
    }
} else {
    print "Skipping step 5\n";
}

#
# STEP 6: issue (& then return) books
#
if ($steps=~ /6/) {
    my $b3 = HTTPD::Bench::ApacheBench->new;
    $b3->concurrency( $concurrency );
    my $b4 = HTTPD::Bench::ApacheBench->new;
    $b4->concurrency( $concurrency );

    my @issues;
    my @returns;
    unless ($short_print) {
        print "Step 6a circulation (checkouts)        ";
    }
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
            ($rand_barcode) = uri_escape_utf8($sth->fetchrow());
        }
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
    if ($short_print) {
        $short_ms.= "|".$b3->total_time."\n";
        $short_psec.="|".(int((1000*$b3->total_requests/$b3->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b3->total_time."ms\t".(int((1000*$b3->total_requests/$b3->total_time)*1000)/1000)." checkouts/sec\n");
    }
    unless ($short_print) {
        print "Step 6b circulation (checkins)         ";
    }
    my $run4 = HTTPD::Bench::ApacheBench::Run->new
        ({ urls => \@returns,
           cookies => [$cookie],
        });
    $b4->add_run($run4);
    $b->add_run($run4);

    # send HTTP request sequences to server and time responses
    $ro = $b4->execute;
    # calculate hits/sec
    if ($short_print) {
        $short_ms.= "|".$b4->total_time."\n";
        $short_psec.="|".(int((1000*$b4->total_requests/$b4->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b4->total_time."ms\t".(int((1000*$b4->total_requests/$b4->total_time)*1000)/1000)." checkins/sec\n");
    }
} else {
    print "Skipping step 6\n";
}

if ($steps=~ /0/) {
    unless ($short_print) {
        print "all transactions at once               ";
    }
    $ro = $b->execute;
    if ($short_print) {
        $short_ms.= "|".$b->total_time."\n";
        $short_psec.="|".(int((1000*$b->total_requests/$b->total_time)*1000)/1000)."\n";
    } else {
        print ("\t".$b->total_time."ms\t".(int((1000*$b->total_requests/$b->total_time)*1000)/1000)." operations/sec\n");
    }
} else {
    print "Skipping 'testing all transactions at once'\n (step 0)";
}

if ($short_print) {
print $short_ms."\n=====\n".$short_psec."\n";
}
