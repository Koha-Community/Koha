$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(qq{
        INSERT IGNORE INTO search_field (name, label, type)
        VALUES ('available', 'available', 'boolean')
    });

    NewVersion( $DBversion, '25735', "Add Elasticsearch field 'available'");
}
