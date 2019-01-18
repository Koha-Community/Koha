$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( column_exists( 'biblio_metadata', 'marcflavour' ) ) {
        $dbh->do(q{
            ALTER TABLE biblio_metadata
                CHANGE COLUMN marcflavour `schema` VARCHAR(16)
        });
    }

    if ( column_exists( 'deletedbiblio_metadata', 'marcflavour' ) ) {
        $dbh->do(q{
            ALTER TABLE deletedbiblio_metadata
                CHANGE COLUMN marcflavour `schema` VARCHAR(16)
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22155 - biblio_metadata.marcflavour should be renamed 'schema')\n";
}
