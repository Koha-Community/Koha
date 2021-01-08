$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    # or perform some test and warn
    # if( !column_exists( 'biblio', 'biblionumber' ) ) {
    #    warn "There is something wrong";
    # }

    $dbh->do("UPDATE systempreferences SET value = REPLACE(value, ',', '|') WHERE variable IN ('OPACSuggestionMandatoryFields','OPACSuggestionUnwantedFields')");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26296, "Replace comma with pipe in OPACSuggestion field preferences");
}
