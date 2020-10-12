$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RecordStaffUserOnCheckout', '0', 'If enabled, when an item is checked out, the user who checked out the item is recorded', '', 'YesNo'); | );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23916 - Add RecordStaffUserOnCheckout syspref)\n";
}
