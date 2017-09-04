$DBversion = "XXX";
if(CheckVersion($DBversion)) {
    # Drop index that might exist because of bug 5337
    if( index_exists('biblioitems', 'ean')) {
        $dbh->do(q{ ALTER TABLE biblioitems DROP INDEX ean });
    }
    if( index_exists('deletedbiblioitems', 'ean')) {
        $dbh->do(q{ ALTER TABLE deletedbiblioitems DROP INDEX ean });
    }

    # Change data type of column
    $dbh->do(q{ ALTER TABLE biblioitems MODIFY COLUMN ean MEDIUMTEXT default NULL });
    $dbh->do(q{ ALTER TABLE deletedbiblioitems MODIFY COLUMN ean MEDIUMTEXT default NULL });

    # Add indexes
    $dbh->do(q{ ALTER TABLE biblioitems ADD INDEX ean ( ean(255) )});
    $dbh->do(q{ ALTER TABLE deletedbiblioitems ADD INDEX ean ( ean(255 ) )});

    print "Upgrade to $DBversion done (Bug 13766 - Make ean mediumtext and add ean indexes)\n";
    SetVersion($DBversion);
}
