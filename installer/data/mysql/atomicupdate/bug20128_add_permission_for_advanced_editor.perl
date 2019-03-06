$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (9,'advanced_editor','Use the advanced cataloging editor')
    });
    if( C4::Context->preference('EnableAdvancedCatalogingEditor') ){
        $dbh->do(q{
            INSERT INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 9, 'advanced_editor' FROM borrowers WHERE borrowernumber IN (SELECT DISTINCT borrowernumber FROM user_permissions WHERE code = 'edit_catalogue');
        });
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20128: Add permission for Advanced Cataloging Editor)\n";
}
