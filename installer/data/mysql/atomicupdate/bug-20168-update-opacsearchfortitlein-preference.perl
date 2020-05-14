$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # Fix the markup in the OPACSearchForTitleIn system preference
    $dbh->do("UPDATE systempreferences SET VALUE = replace( value, '</li>', ''), value = REPLACE( value, '<li>', '') WHERE VARIABLE = 'OPACSearchForTitleIn';");

    NewVersion( $DBversion, 20168, "Update OPACSearchForTitleIn to work with Bootstrap 4");
}
