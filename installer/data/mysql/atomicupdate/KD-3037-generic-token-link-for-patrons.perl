$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "INSERT INTO `borrower_attribute_types` (`code`, `description`, `unique_id`) VALUES ('LTOKEN','Token for sending data to patrons',1)" );
    $dbh->do("INSERT INTO `letter` (module, code, name, title, content, message_transport_type)
    VALUES ('members','PATRON_DATA','Patron data','Your library data',
    '<p>Dear <<borrowers.firstname>> <<borrowers.surname>>, you can see your data in here.</p><p><<mydataurl>></p><p> The link will expire after you open it </p>',
    'email')");


    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3037 - Generic token link for patrons)\n";
}
