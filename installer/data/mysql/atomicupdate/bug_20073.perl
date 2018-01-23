$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE search_field CHANGE COLUMN type type ENUM('', 'string', 'date', 'number', 'boolean', 'sum', 'isbn', 'stdno') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20073 - Add new types for Elasticsearch fields)\n";
}
