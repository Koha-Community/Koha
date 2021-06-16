$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do("ALTER TABLE statistics ADD COLUMN usercode varchar(10) AFTER ccode");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 7021, "Bug 7021 - Reintroduce usercode column");
}
