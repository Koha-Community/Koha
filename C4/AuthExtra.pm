package C4::AuthExtra;

=expl
get_timeout returns timeout based on user's category
value is in sysprefs variable timeout2
value is in yaml-format example USERCATEGORY1: 600
=cut

use Data::Dumper;
use C4::Context;
use Try::Tiny;
use YAML;

##################################
#gets timeout based on borrower's category
sub get_timeout {
    my ($cardnumber,$timeout) = @_;
    $cardnumber= uc(trim($cardnumber));
    my $retval=$timeout;
    my $dbh   = C4::Context->dbh;
    my $valueyaml;

    try {

        #get catgorycode
        my ($categorycode,$valueyaml);
        my $sql="select categorycode from borrowers where upper(trim(cardnumber))='".$cardnumber."'";
        my $sth=$dbh->prepare($sql);
        $sth->execute();        
        while (@row=$sth->fetchrow_array()) {
            $categorycode=$row[0];
        }
        $sth->finish();

        #get timeout2's valueyaml from systempreferences
        $sql="select value from systempreferences where variable='timeout2'";
        $sth=$dbh->prepare($sql);
        $sth->execute();
        while (@row=$sth->fetchrow_array()) {
            $valueyaml=$row[0];
        }
        $sth->finish();
        
        #get category's timeout
        my $timeouts=Load($valueyaml);
        my $newtimeout=$timeouts->{$categorycode};
        if($newtimeout > 0) {
            $retval=$newtimeout;
        }

    }
    catch {
       $retval=$timeout;
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



