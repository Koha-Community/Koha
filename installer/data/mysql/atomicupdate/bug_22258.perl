$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`,`value`,`explanation`,`options`,`type`) VALUES
        ('ElasticsearchMARCFormat', 'ISO2709', 'ISO2709|ARRAY', 'Elasticsearch MARC format. ISO2709 format is recommended as it is faster and takes less space, whereas array is searchable.', 'Choice')
    });

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22258 - Add ElasticsearchMARCFormat preference)\n";
}
