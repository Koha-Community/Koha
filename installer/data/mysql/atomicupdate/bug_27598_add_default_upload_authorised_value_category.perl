$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $sth = $dbh->prepare("SELECT category_name FROM authorised_value_categories WHERE category_name='UPLOAD'");
    $sth->execute;
    my ($value) = $sth->fetchrow;
    if( $value ){
        print "The UPLOAD authorized value category exists. Update the 'is_system' value to 1.\n";
        $dbh->do( "UPDATE authorised_value_categories SET is_system = 1 WHERE category_name = 'UPLOAD'" );
    } else {
        print "The UPLOAD authorized value category does not exist. Create it.\n";
        $dbh->do( "INSERT IGNORE INTO authorised_value_categories (category_name, is_system) VALUES ('UPLOAD', 1)" );
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 27598, "Add UPLOAD as a built-in system authorized value category");
}
