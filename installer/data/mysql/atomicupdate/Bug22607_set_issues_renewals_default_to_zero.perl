$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( "UPDATE issues SET renewals = 0 WHERE renewals IS NULL" );
    $dbh->do( "UPDATE old_issues SET renewals = 0 WHERE renewals IS NULL" );

    $dbh->do( "ALTER TABLE issues MODIFY COLUMN renewals tinyint(4) NOT NULL default 0");
    $dbh->do( "ALTER TABLE old_issues MODIFY COLUMN renewals tinyint(4) NOT NULL default 0");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Set default value of issues.renewals to 0)\n";
}
