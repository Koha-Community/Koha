$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE search_marc_to_field SET sort = 1 WHERE sort IS NULL" );
    $dbh->do( "ALTER TABLE search_marc_to_field MODIFY COLUMN sort tinyint(1) DEFAULT 1 NOT NULL COMMENT 'Sort defaults to 1 (Yes) and creates sort fields in the index, 0 (no) will prevent this'" );
    NewVersion( $DBversion, 27316, "In Elastisearch mappings convert NULL (Undef) for sort to 1 (Yes)");
}
