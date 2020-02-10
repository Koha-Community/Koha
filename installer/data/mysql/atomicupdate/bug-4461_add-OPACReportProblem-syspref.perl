$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('OPACReportProblem', 0, NULL, 'Allow patrons to submit problem reports for OPAC pages to the library or Koha Administrator', 'YesNo') });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4461 - Add OPACReportProblem system preference)\n";
}
