package C4::AuthExtra;

=expl
get_timeout returns timeout based on user's category
value is in sysprefs variable timeout
value is in yaml-format example USERCATEGORY1: 600
=cut

use Data::Dumper;
use C4::Context;
use Try::Tiny;
use YAML;
use Log::Log4perl;
use Scalar::Util;

##################################
#gets timeout based on borrower's category
sub get_timeout {
    my ($cardnumber,$timeout) = @_;
    my $dbh   = C4::Context->dbh;
    my $valueyaml;
    my $retval = $timeout;
    my $logger   = Log::Log4perl->get_logger();
    try {

        #get catgorycode
        my $categorycode = "DEFAULT";

        if ($cardnumber) {
            $cardnumber = trim($cardnumber);            
            my $sql="select categorycode from borrowers where trim(cardnumber)='".$cardnumber."'";
            my $sth=$dbh->prepare($sql);
            $sth->execute();        
            while (@row=$sth->fetchrow_array()) {
                $categorycode=$row[0];
            }
            $sth->finish();
        } 
        #get timeout's valueyaml from systempreferences
        $sql="select value from systempreferences where variable='timeout2'";
        $sth=$dbh->prepare($sql);
        $sth->execute();
        while (@row=$sth->fetchrow_array()) {
            $valueyaml=$row[0];
        }
        $sth->finish();
       
        #if valueyaml is numeric, convert it to DEFAULT:valueyaml and save it to syspref timeout
        if(Scalar::Util::looks_like_number($valueyaml)) {
           $valueyaml = convert_number_to_yaml($valueyaml);
        }
        #get category's timeout
        my $timeouts=Load($valueyaml);
        my $newtimeout=$timeouts->{$categorycode};
        if($newtimeout > 0) {
            $retval=$newtimeout;
        }
    }
    catch {
       $logger->warn("Timeout or YAML error  $_");
    };

    return($retval);
}

#############################################
#converts old timeout number to yaml DEFAULT:number and saves it to db
sub convert_number_to_yaml {
    my ($timeout) = @_;
    my $retval="---\nDEFAULT:"." ".$timeout;
    my $logger   = Log::Log4perl->get_logger();
    my $dbh = C4::Context->dbh; 

    try {
        my $sth=$dbh->prepare("update systempreferences set value = '".$retval."' where variable = 'old_timeout'");
        $sth->execute();
        $sth->finish();
    }
    catch {
       $retval = $timeout;
       $logger->warn("YAML conversion error  $_");
    };
    return($retval);
}

##############################################
sub trim {
    my ($retval)=@_;
    $retval =~ s/^\s+|\s+$//g;
    return($retval);
}

1;



