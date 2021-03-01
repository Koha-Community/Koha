$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        UPDATE items
        LEFT JOIN issues ON issues.itemnumber=items.itemnumber
        SET items.onloan=CAST(issues.date_due AS DATE)
        WHERE items.onloan IS NULL
    |);

    NewVersion( $DBversion, 27808, "Adjust items.onloan if needed");
}
