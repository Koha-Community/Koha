#!/usr/bin/perl

use C4::Context;
use Try::Tiny;
use Koha::Config;

my $result = add_borrowercategorytimeout_pref();

#creates a new and empty syspref BorrowerCategoryTimeout
sub add_borrowercategorytimeout_pref() {
    my $insert;
    my $retval = 0;

    if(!Koha::Config::SysPrefs->find('BorrowerCategoryTimeout')) {
        my $dbh = C4::Context->dbh();
        my $error;
        try {
            my $sql = "insert into systempreferences(variable,explanation)"
                     ." values('BorrowerCategoryTimeout','Timeout based on borrower''s category')";
            my $sth = $dbh->prepare($sql);
            $sth->execute();
            $sth->finish();
        }
        catch {
            $error = $_;
            print "Error inserting syspref BorrowerCategoryTimeout ".$error;
        };

        if($error) {
            $retval = -1;
        }

        $dbh->disconnect();
    }
    return($retval);
}






