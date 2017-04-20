$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE collections_tracking
            ADD origin_branchcode VARCHAR(10) NULL DEFAULT NULL
    });

    $dbh->do(q{
        ALTER TABLE collections_tracking
            ADD transfer_branch VARCHAR(10) NULL DEFAULT NULL
    });

    $dbh->do(q{
        ALTER TABLE collections_tracking add date_added DATETIME
    });

    $dbh->do(q{
        ALTER TABLE collections_tracking add timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    });

    $dbh->do(q{
        ALTER TABLE collections
            ADD owningBranchcode VARCHAR(10) NULL DEFAULT NULL
    });

    $dbh->do(q{
        ALTER TABLE collections
            ADD CONSTRAINT collections_owning_1 FOREIGN KEY (owningBranchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
    });

    $dbh->do(q{
        ALTER TABLE collections_tracking
            ADD CONSTRAINT collections_origin_1 FOREIGN KEY (origin_branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
    });

    $dbh->do(q{
        ALTER TABLE collections_tracking
            ADD CONSTRAINT collections_transfer_1 FOREIGN KEY (transfer_branch) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
    });


    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-139/Bug 8836 Resurrecting rotating collections)\n";
}
