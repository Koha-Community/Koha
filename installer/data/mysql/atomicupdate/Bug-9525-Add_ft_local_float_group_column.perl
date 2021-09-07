$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do("ALTER TABLE library_groups ADD COLUMN IF NOT EXISTS ft_local_float_group tinyint(1) NOT NULL DEFAULT 0 AFTER ft_local_hold_group");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 9525, "Add option to set group as local float group");
}
