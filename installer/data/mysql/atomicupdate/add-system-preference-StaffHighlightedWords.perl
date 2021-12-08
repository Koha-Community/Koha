$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
        VALUES ('StaffHighlightedWords','1','','Activate or not highlighting of search terms for staff interface','YesNo ')
    });
    NewVersion( $DBversion, '20398', 'Add system preference StaffHighlightedWords');
}
