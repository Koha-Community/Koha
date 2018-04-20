#!/usr/bin/perl

use MongoDB;
use Pod::Usage;
use Getopt::Long;
use Data::Dumper;
use Koha::DateUtils;
use DateTime;
use POSIX qw{strftime};

use Koha::MongoDB::Config;
use Koha::MongoDB::Users;
use Koha::MongoDB::Logs;

my $verbose     = 0;
my $help        = 0;
my $minutes     = 15;
my $today = DateTime->now();
my $startdate;
my $enddate;
my $count = 0;

GetOptions( 
    'v|verbose'   => \$verbose,
    'h|help'      => \$help,
    'm|minutes=i'    => \$minutes
);

my $usage = << 'ENDUSAGE';

This script fetches action logs and pushes them to MongoDB from long time keeping.

This script has the following parameters :
    -h --help: this message
    -v --verbose
    -m --minutes: Look x minutes to past to pull data, default is 15.


ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $starttime = time();
print "Start time: ".strftime("\%H:\%M:\%S", localtime($starttime))."\n";


my $timeago = $starttime - ($minutes*60);
$startdate = strftime("\%Y-\%m-\%d \%H:\%M", localtime($timeago));
$enddate = strftime("\%Y-\%m-\%d \%H:\%M", localtime($starttime));

my $config = new Koha::MongoDB::Config;
my $users = new Koha::MongoDB::Users;
my $logs = new Koha::MongoDB::Logs;
my $client = $config->mongoClient();


my $actionlogs = $logs->getActionLogs($startdate, $enddate);

foreach my $actionlog (@{$actionlogs}) {

    my $user = $users->checkUser($actionlog->{user});
    my $object = $users->checkUser($actionlog->{object});
    my $findlog = $logs->checkLog($actionlog, $user, $object);

    if($actionlog->{object} && !$findlog) {
        my $objectuser = $users->getUser($actionlog->{object});
        my $objectuserId = $users->setUser($objectuser);

        my $sourceuser = $users->getUser($actionlog->{user});
        my $sourceuserId = $users->setUser($sourceuser);

        my $result = $logs->setUserLogs($actionlog, $sourceuserId, $objectuserId, $objectuser->{cardnumber}, $objectuser->{borrowernumber});
        print Dumper $result if $verbose;
        $count++;
    }
}

my $endtime = time();
print "End time: ".strftime("\%H:\%M:\%S", localtime($endtime))."\n";
my $time = $endtime - $starttime;
print "Count: ".$count." - Time: ".strftime("\%H:\%M:\%S", gmtime($time))."\n";