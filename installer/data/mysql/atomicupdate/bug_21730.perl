$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:

    $dbh->do( "INSERT IGNORE INTO authorised_value_categories (category_name) VALUES ('PA_CLASS');");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21730: Add new authorised value category PA_CLASS)\n";
}
