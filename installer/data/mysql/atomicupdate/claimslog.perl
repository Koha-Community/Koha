$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        UPDATE action_logs SET module = 'CLAIMS'
        WHERE module = 'ACQUISITIONS' AND ( action = 'SERIAL CLAIM' OR action = 'ACQUISITION CLAIM')
    });

    $dbh->do(q{
        UPDATE systempreferences SET variable = 'ClaimsLog' WHERE variable = 'LetterLog';
    });

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, XXXXX, "Description" );
}
