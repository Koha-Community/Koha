$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless(
        primary_key_exists('import_record_matches','import_record_id') &&
        primary_key_exists('import_record_matches','candidate_match_id')
    ){
        $dbh->do( "ALTER TABLE import_record_matches DROP PRIMARY KEY" );
        $dbh->do( "ALTER TABLE import_record_matches ADD PRIMARY KEY (import_record_id,candidate_match_id)" );
    }

    NewVersion( $DBversion, 26326, "Add primary key to import_record_matches");
}
