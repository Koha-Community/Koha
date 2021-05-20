$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # REFUND
    $dbh->do( "UPDATE account_credit_types SET description = 'Refund' WHERE code = 'REFUND'" );

    NewVersion( $DBversion, 27779, "Simplify credit descriptions");
}
