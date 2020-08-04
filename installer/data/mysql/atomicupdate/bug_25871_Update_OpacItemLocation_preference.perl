$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE systempreferences SET options = "callnum|ccode|location|library"
        WHERE variable = "OpacItemLocation"
    });
    NewVersion( $DBversion, 25871, "Add library option to OpacItemLocation");
}
