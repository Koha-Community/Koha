$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('DefaultHoldExpirationdate','0','','Automatically set default expiration date for holds','YesNo') });
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('DefaultHoldExpirationdatePeriod','0','','How long into the future default expiration date is set to be.','integer') });
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('DefaultHoldExpirationdateUnitOfTime','days','days|months|years','Which unit of time is used when setting the default expiration date. ','choice') });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26498, "Bug 26498 - Add option to set a default expire date for holds at reservation time");
}
