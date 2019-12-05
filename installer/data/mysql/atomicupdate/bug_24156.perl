$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( TableExists( 'tables_settings' ) ) {
        $dbh->do(q|
            CREATE TABLE tables_settings (
                module varchar(255) NOT NULL,
                page varchar(255) NOT NULL,
                tablename varchar(255) NOT NULL,
                default_display_length smallint(6) NOT NULL DEFAULT 20,
                default_sort_order varchar(255),
                PRIMARY KEY(module (191), page (191), tablename (191) )
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24156 - Add new table tables_settings)\n";
}
