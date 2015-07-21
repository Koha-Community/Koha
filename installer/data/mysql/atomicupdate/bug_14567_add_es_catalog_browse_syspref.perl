$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES
        ('OpacBrowseSearch', '0',NULL, "Elasticsearch only: add a page allowing users to 'browse' all items in the collection",'YesNo')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14567: Add OpacBrowseSearch syspref)\n";
}
