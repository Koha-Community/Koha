$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`,`type`) VALUES
        ('OPACnumSearchResultsDropdown', 0, NULL, 'Enable option list of number of results per page to show in OPAC search results','YesNo'),
        ('numSearchResultsDropdown', 0, NULL, 'Enable option list of number of results per page to show in staff client search results','YesNo')
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14715 - Add sysprefs numSearchResultsDropdown and OPACnumSearchResultsDropdown)\n";
}
