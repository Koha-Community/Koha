$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        DELETE FROM circulation_rules
        WHERE rule_name = 'rentaldiscount' AND rule_value=''
    });
    NewVersion( $DBversion, 28774, "Delete blank rental discounts");
}
