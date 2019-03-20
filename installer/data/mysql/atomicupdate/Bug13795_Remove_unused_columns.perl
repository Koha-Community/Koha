$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( column_exists('statistics', 'associatedborrower') ) {
        $dbh->do(q{ ALTER TABLE statistics DROP COLUMN associatedborrower });
    }
    if( column_exists('statistics', 'usercode') ) {
        $dbh->do(q{ ALTER TABLE statistics DROP COLUMN usercode });
    }

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 13795 - Delete unused fields from statistics table)\n";
}
