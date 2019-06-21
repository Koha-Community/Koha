$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('ILLCheckAvailability', '0', 'If enabled, during the ILL request process third party sources will be checked for current availability', '', 'YesNo'); | );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23173 - Add ILLCheckAvailability syspref)\n";
}
