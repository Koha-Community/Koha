$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('ChargeFinesOnClosedDays', '0', NULL, 'Charge fines on days the library is closed.', 'YesNo')
    |);

    NewVersion( $DBversion, 27835, "Add new system preference ChargeFinesOnClosedDays");
}
