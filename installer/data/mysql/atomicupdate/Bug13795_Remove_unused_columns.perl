$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE statistics
         DROP COLUMN associatedborrower
         DROP COLUMN usercode
    });

    SetVersion($DBversion);

    print "Upgrade to $DBversion done (Bug 13795 - Delete unused fields from statistics table)\n";
}
