$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do('SET FOREIGN_KEY_CHECKS=0');

    # Change columns accordingly
    $dbh->do(q{
        ALTER TABLE tags_index
            MODIFY COLUMN term VARCHAR(191) COLLATE utf8mb4_bin NOT NULL;
    });

    $dbh->do(q{
        ALTER TABLE tags_approval
            MODIFY COLUMN term VARCHAR(191) COLLATE utf8mb4_bin NOT NULL;
    });

    $dbh->do(q{
        ALTER TABLE tags_all
            MODIFY COLUMN term VARCHAR(191) COLLATE utf8mb4_bin NOT NULL;
    });

    $dbh->do('SET FOREIGN_KEY_CHECKS=1');

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21846 - Using emoji as tags has broken weights)\n";
}
