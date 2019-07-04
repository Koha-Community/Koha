$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !TableExists( 'itemtypes_branches' ) ) {
       $dbh->do( "
            CREATE TABLE itemtypes_branches( -- association table between authorised_values and branches
                itemtype VARCHAR(10) NOT NULL,
                branchcode VARCHAR(10) NOT NULL,
                FOREIGN KEY (itemtype) REFERENCES itemtypes(itemtype) ON DELETE CASCADE,
                FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15497 - Add itemtypes_branches table)\n";
}
