$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( !column_exists( 'categories', 'canbeguarantee') ){
        $dbh->do("ALTER TABLE categories ADD COLUMN `canbeguarantee` tinyint(1) NOT NULL default '0' AFTER `checkprevcheckout`");
        $dbh->do("UPDATE categories SET canbeguarantee = 1 WHERE category_type = 'P' OR category_type = 'C'");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 12446 - Ability to allow guarantor relationship for all patron category types)\n";
}