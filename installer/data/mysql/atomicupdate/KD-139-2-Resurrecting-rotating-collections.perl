$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE collections_tracking
            ADD transferred tinyint(1) DEFAULT '0'
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-139-2/Bug 8836 Fix atomicupdate)\n";
}
