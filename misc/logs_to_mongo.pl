#!/usr/bin/perl
#this program copies borrowers' log data from table action_logs_cache to mongodb

use Getopt::Long;

use C4::Context;

use Koha::MongoDB;

my $loopcount=0;
my $limit=100;
my $copied=0;
my $help=0;

GetOptions(
    'h|help'      => \$help,
    'l|limit=i'     => \$limit
);

my $usage = << 'ENDUSAGE';

This script moves action_logs_cache's data to MongoDB.

This script has the following parameters :
    -h --help: this message
    -l --limit: limiting the sql query to get smaller batch

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $mongo = Koha::MongoDB->new;

###################################################
# main loop copies logs and waits one minute before new round
# action happens in sub copy_log 
# if $loopcount does not increase, script will run
while($loopcount < 5) {
    
    my $copied=$mongo->push_action_logs($limit);
    #sleep(60);
    #$loopcount++;
}
