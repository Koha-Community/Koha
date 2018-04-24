$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
      INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
      VALUES ('ILLOpacbackends',NULL,NULL,'ILL backends to enabled for OPAC initiated requests','multiple');
    |);

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20639 - Add ILLOpacbackends syspref)\n";
}
