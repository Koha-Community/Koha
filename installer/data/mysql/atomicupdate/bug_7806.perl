$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    eval {
        local $dbh->{PrintError} = 0;
        $dbh->do(q|
            UPDATE aqorders
            SET datecancellationprinted = NULL
            WHERE datecancellationprinted = '0000-00-00'
        |);
        $dbh->do(q|
            UPDATE old_issues
            SET returndate = NULL
            WHERE returndate = '0000-00-00'
        |);

    };
    NewVersion( $DBversion, 7806, "Remove remaining possible 0000-00-00 values");
}
