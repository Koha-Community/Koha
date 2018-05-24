#!/usr/bin/perl
#this program copies borrowers' log data from table action_logs_cache to mongodb

use C4::Context;
use Getopt::Long;
use Try::Tiny;
use Koha::MongoDB::Logs;
use Koha::MongoDB::Users;
use Data::Dumper;
my $loopcount=0;
my $copied=0;
my $help=0;

GetOptions( 
    'h|help'      => \$help
);

my $usage = << 'ENDUSAGE';

This script moves action_logs_cache's data to MongoDB.

This script has the following parameters :
    -h --help: this message

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}


###################################################
# main loop copies logs and waits one minute before new round
# action happens in sub copy_log 
# if $loopcount does not increase, script will run
while($loopcount < 5) {
    
    my $copied=copy_log();
    sleep(60);
    #$loopcount++;
}

####################################################
# copies data from table action_logs to mongodb
sub copy_log {

    my $retval=0;
    my $logs = new Koha::MongoDB::Logs;
    my $users = new Koha::MongoDB::Users;

    try {
        # all rows from table
        my $actionlogs = $logs->getActionCacheLogs();
        
        foreach my $actionlog (@{$actionlogs}) {
            my $user = $users->checkUser($actionlog->{user});
            my $object = $users->checkUser($actionlog->{object});
            my $borrowernumber = $actionlog->{object};
            my $findlog = $logs->checkLog($actionlog, $user, $object); 
            my $action_id = $actionlog->{action_id};

            # if borrower's log and not already in mongo
            if($actionlog->{object} && !$findlog) {
                my $objectuser = $users->getUser($actionlog->{object});
                my $objectuserId = $users->setUser($objectuser);
                my $sourceuser;
                my $sourceuserId;
               
                if($actionlog->{user}) {
                    $sourceuser = $users->getUser($actionlog->{user});
                    $sourceuserId = $users->setUser($sourceuser);
                }

                my $result = $logs->setUserLogs($actionlog, $sourceuserId, $objectuserId, $objectuser->{cardnumber}, $objectuser->{borrowernumber});
            }
            
            #remove row from table
            remove_logs_cache($action_id);
            sleep(1);
        }        
    }
    catch {
        $retval=-1;
        warn "caught error: $_";
    };
    return($retval);
}

####################################################
# removes one row from table action_logs_cache
sub remove_logs_cache {
    my @args = @_;
    my $action_id = $args[0];
    my $sqlstring = "delete from action_logs_cache where action_id = ".$action_id;
    my $dbh = C4::Context->dbh();
    my $query = $dbh->prepare($sqlstring);
    $query->execute() or die;
    $dbh->disconnect();
}
