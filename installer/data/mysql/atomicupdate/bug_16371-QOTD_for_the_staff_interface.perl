$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do( "UPDATE systempreferences SET value = '', options = 'intranet,opac', explanation = 'Enable or disable display of Quote of the Day on the OPAC and staff interface home page', type = 'multiple' WHERE variable = 'QuoteOfTheDay'" );

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 16371, "Bug 16371 - Quote of the Day (QOTD) for the staff interface ");
}
