#!/usr/bin/perl

use MongoDB;
use File::Basename;
use XML::Simple;
use Data::Dumper;
use Koha::Patrons;
use C4::Log;
use Pod::Usage;
use Getopt::Long;
use Koha::DateUtils;
use DateTime;
use POSIX qw{strftime};

my $verbose     = 0;
my $help        = 0;
my $days        = 0;
my $today = DateTime->today();
my $startdate;
my $enddate;
my $count = 0;

GetOptions( 
    'v|verbose'   => \$verbose,
    'h|help'      => \$help,
    'd|days=i'    => \$days
);

my $usage = << 'ENDUSAGE';

This script fetches action logs and pushes them to MongoDB from long time keeping.

This script has the following parameters :
    -h --help: this message
    -v --verbose
    -d --days: Look x days to past to pull data, default is today.


ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $starttime = time();
print "Start time: ".strftime("\%H:\%M:\%S", gmtime($starttime))."\n";


if ($days) {
    my $dt = $today->clone();
    $dt->add(days => -$days);
    $startdate = $dt->ymd();

    $dt = $today->clone();
    $dt->add(days => -1);
    $enddate = $dt->ymd();
} else {
    $startdate = $today->ymd();
    $enddate = $today->ymd();
}


my $settings = getSettings();
my $client = mongoClient($settings);


my $actionlogs = getActionLogs($startdate,$enddate);
foreach my $actionlog (@{$actionlogs}) {

    my $user = checkUser($actionlog->{user});
    my $object = checkUser($actionlog->{object});
    my $findlog = checkLog($actionlog, $user, $object);

    if($actionlog->{object} && !$findlog) {
        my $objectuser = getPatron($actionlog->{object});
        my $objectuserId = setUser($objectuser);

        my $sourceuser = getPatron($actionlog->{user});
        my $sourceuserId = setUser($sourceuser);

        my $success = setUserLogs($actionlog, $sourceuserId, $objectuserId, $objectuser->{cardnumber}, $objectuser->{borrowernumber});
        $count++;
    }
}

my $endtime = time();
print "End time: ".strftime("\%H:\%M:\%S", gmtime($endtime))."\n";
my $time = $endtime - $starttime;
print "Count: ".$count." - Time: ".strftime("\%H:\%M:\%S", gmtime($time))."\n";

sub getPatron{
    my $borrowernumber = shift;
    return Koha::Patrons->find( $borrowernumber )->unblessed;
}

sub setUser{
    my $user = shift;

    my $users = $client->ns($settings->{database}.'.users');
    my $finduser = checkUser($user->{borrowernumber});
    my $objectId;

    unless ($finduser) {

        my $result = $users->insert_one({ 
            borrowernumber => $user->{borrowernumber},
            firsname => $user->{firstname},
            surname => $user->{surname},
            date => DateTime->today()->ymd(),
            library => $user->{branchcode},
            cardnumber => $user->{cardnumber}
            });
        $objectId = $result->inserted_id;

    } else {
        $objectId = $finduser->{_id};
    }

    return $objectId;
}

sub getActionLogs{
    my $startdate = shift;
    my $enddate = shift;
    my @modules = ['MEMBERS', 'CIRCULATION', 'FINES', 'NOTICES', 'SS'];
    my $results = GetLogs( $startdate, $enddate, undef, @modules, undef, undef, undef, undef );

    return $results;
}

sub setUserLogs{
    my $actionlog = shift;
    my $sourceuserId = shift;
    my $objectuserId = shift;
    my $cardnumber = shift;
    my $borrowernumber = shift;

    my $success = 0;

    my $logs = $client->ns($settings->{database}.'.user_logs');
    my $result = $logs->insert_one({
        sourceuser       => $sourceuserId,
        objectuser       => $objectuserId,
        objectcardnumber => $cardnumber,
        objectborrowernumber => $borrowernumber,
        action           => $actionlog->{action},
        info             => $actionlog->{info},
        timestamp        => $actionlog->{timestamp}

        });
    $success = 1;
    print Dumper $actionlog if $verbose;    

    return $success;
}

sub checkLog {
    my $actionlog = shift;
    my $sourceuserId = shift;
    my $objectuserId = shift;

    my $logs = $client->ns($settings->{database}.'.user_logs');
    my $findlog = $logs->find_one({
        sourceuser => $sourceuserId->{_id}, 
        objectuser => $objectuserId->{_id}, 
        action => $actionlog->{action}, 
        timestamp => $actionlog->{timestamp}});
    return $findlog;
}

sub checkUser {
    my $borrowernumber = shift;

    my $users = $client->ns($settings->{database}.'.users');
    my $finduser = $users->find_one({borrowernumber => $borrowernumber});
    return $finduser;
}

sub mongoClient {
    my $settings = shift;

    my $connection = MongoDB::MongoClient->new(
        host => $settings->{host},
        username => $settings->{username},
        password => $settings->{password},
        db_name => $settings->{database}
    );

    return $connection;
}

sub loadConfigXml{
    my $configs = {};
    my $xmlPath = getConfigXmlPath();

    if( -e $xmlPath ){
        my $simple = XML::Simple->new;
        $configs = $simple->XMLin($xmlPath);
    }
    return $configs;
}

sub getConfigXmlPath{
    my $kohaConfigPath = $ENV{'KOHA_CONF'};
    my $kohaPath = $ENV{KOHA_PATH};
    my $configFile = "mongodb-config.xml";
    my($file, $path, $ext) = fileparse($kohaConfigPath);
    my $procurementConfigPath = $path . $configFile; # use the same path as koha_config.xml file
    return $procurementConfigPath;
}

sub getSettings{
    my $settings;
    if(!$settings){
        my $confs = loadConfigXml();
        if($confs){
            $settings = $confs;
        }
    }

    return $settings;
}