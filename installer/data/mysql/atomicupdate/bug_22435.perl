$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO account_offset_types () VALUES ( 'CREATE' )" );
    $dbh->do( "UPDATE account_offsets SET type = 'CREATE' WHERE type != 'OVERDUE_INCREASE' AND type != 'OVERDUE_DECREASE' AND ( debit_id IS NULL OR credit_id IS NULL)" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 22435, "Update offsets to CREATE type");
}
