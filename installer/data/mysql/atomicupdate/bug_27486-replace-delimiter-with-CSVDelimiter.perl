$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do(q{UPDATE systempreferences set variable="CSVDelimiter" WHERE variable="delimiter"});

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 27486, "Renaming 'delimiter' syspref to 'CSVDelimiter'");
}
