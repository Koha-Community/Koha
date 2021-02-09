$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        UPDATE systempreferences
        value=REPLACE(value, '|', ',')
        WHERE variable="OPACHoldsIfAvailableAtPickupExceptions"
           OR variable="BatchCheckoutsValidCategories"
    });
    NewVersion( $DBversion, 27652, "Separate values for OPACHoldsIfAvailableAtPickupExceptions and BatchCheckoutsValidCategories with comma");
}
