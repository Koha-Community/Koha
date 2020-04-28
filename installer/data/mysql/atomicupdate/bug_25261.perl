$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('CircConfirmParts', '0', NULL, 'Require staff to confirm that all parts of an item are present at checkin/checkout.', 'YesNo') });

    NewVersion( $DBversion, 25261, "Add CircConfirmParts syspref");
}
