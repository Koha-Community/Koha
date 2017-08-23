$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO authorised_value_categories (category_name)
            VALUES ("GENRE")
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-211-2: Add genre to authorized_values_categories\n";
}
