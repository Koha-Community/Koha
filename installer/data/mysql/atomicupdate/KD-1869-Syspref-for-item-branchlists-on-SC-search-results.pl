$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(
        "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('ShowBranchListOnSearchResults', '1', null, 'Show a list branches with availability information on search results', 'YesNo');"
    );
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1869 - Syspref for item branchlists on SC search resultsn)\n";
}
