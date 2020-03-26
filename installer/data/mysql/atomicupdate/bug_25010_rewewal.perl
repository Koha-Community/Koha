$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "UPDATE account_debit_types SET description = REPLACE(description,'Rewewal','Renewal') WHERE description like '%Rewewal%'" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 25010, "Fix typo in account_debit_type description");
}
