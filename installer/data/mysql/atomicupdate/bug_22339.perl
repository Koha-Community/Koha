$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='007_/0'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='007_/1' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='ff7-00')
            )
    |);

    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='007_/1'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='007_/2' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='ff7-01')
            )
    |);

    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='007_/2'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='007_/3' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='ff7-02')
            )
    |);

    # N.B. ff7-01-02 really is 00-01!
    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='007_/0-1'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='007_/1-2' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='ff7-01-02')
            )
    |);

    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='008_/0-5'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='008_/1-5' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='date-entered-on-file')
            )
    |);

    $dbh->do( q|
        UPDATE search_marc_map SET marc_field='leader_/0-4'
          WHERE marc_type IN ('marc21', 'normarc') AND marc_field='leader_/1-5' AND id IN
            (SELECT search_marc_map_id FROM search_marc_to_field WHERE search_field_id IN
              (SELECT id FROM search_field WHERE label='llength')
            )
    |);

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22339 - Fix search field mappings of MARC fixed fields)\n";
}
