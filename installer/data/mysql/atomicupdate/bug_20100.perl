$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
INSERT IGNORE INTO systempreferences ( value, variable, options, explanation, type ) VALUES ( '0', 'ProtectSuperlibPrivs', NULL, 'If enabled, non-superlibrarians cannot set superlibrarian privileges', 'YesNo' );
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20100: Should a non-superlibrarian be able to add superlibrarian privileges?)\n";
}
