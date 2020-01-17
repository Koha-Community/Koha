$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # Update daterequested from datesent for stockrotation
    $dbh->do(
        qq{
            UPDATE
              `branchtransfers`
            SET
              `daterequested` = `datesent`,
              `datesent` = NULL
            WHERE
              `reason` LIKE 'Stockrotation%'
            AND
              `datearrived` IS NULL
          }
    );

    NewVersion( $DBversion, 24446, "Update stockrotation 'daterequested' field in transfers table" );
}
