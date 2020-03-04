$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE `search_field` MODIFY COLUMN `type` enum('','string','date','number','boolean','sum','isbn','stdno','year') NOT NULL" );
    $dbh->do( "UPDATE `search_field` SET type = 'year' WHERE name = 'date-of-publication'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14957 - Add 'year' type to improve sorting behaviour)\n";
}
