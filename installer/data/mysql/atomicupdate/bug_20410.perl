$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        DELETE FROM systempreferences WHERE variable="OpacGroupResults"
    });

    NewVersion( $DBversion, 20410, "Remove OpacGroupResults");
}
