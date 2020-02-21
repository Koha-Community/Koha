$DBversion = '19.12.00.XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );
    $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES
                ('MaxTotalSuggestions','','Number of total suggestions','Free'),
                ('NumberOfSuggestionDays','','days','Free')
            });
    # or perform some test and warn
    # if( !column_exists( 'biblio', 'biblionumber' ) ) {
    #    warn "There is something wrong";
    # }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22774 - Limit Purchase Suggestion in a specified Time period)\n";
}
