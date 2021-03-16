$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('ChargeFinesOnCloseDay', '1', NULL, 'Charge fines on close day.', 'YesNo')
    |);

    NewVersion( $DBversion, 27835, "Add new system preference ChargeFinesOnCloseDay");
}
