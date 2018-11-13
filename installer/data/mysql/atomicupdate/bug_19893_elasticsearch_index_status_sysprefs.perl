$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`,`value`,`explanation`,`options`,`type`) VALUES
        ('ElasticsearchIndexStatus_biblios', '0', 'Biblios index status', NULL, NULL),
        ('ElasticsearchIndexStatus_authorities', '0', 'Authorities index status', NULL, NULL)
    });

    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 19893 - Add elasticsearch index status preferences)\n";
}
