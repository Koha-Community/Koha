$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE search_marc_map CHANGE marc_type `marc_type` enum('marc21','normarc','unimarc') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'what MARC type this map is for';
    });
    NewVersion( $DBversion, 23204, "Change enum order for marc_type in search_marc_map to fix sorting");
}
