$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET type="Free" WHERE variable="OverDriveClientSecret" OR variable="RecordedBooksClientSecret"
    });
    $dbh->do(q{
        UPDATE systempreferences SET type="integer" WHERE variable="UsageStats"
    });
    $dbh->do(q{
        UPDATE systempreferences
        SET value="0"
        WHERE ( ( type = "YesNo" AND ( value NOT IN ( "1", "0" ) OR value IS NULL ) ) )
    });

    NewVersion( $DBversion, 22824, "Update syspref values for YesNo");
}
