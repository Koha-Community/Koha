$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{UPDATE systempreferences SET `type` = 'Choice' WHERE `variable` = 'Mana'});
    NewVersion( $DBversion, 27349, "Update type for Mana sytem preference to Choice");
}
