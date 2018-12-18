$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        INSERT IGNORE INTO permissions (module_bit,code,description)
        VALUES
        (3,'manage_additional_fields','Add, edit, or delete additional custom fields for baskets or subscriptions (also requires order_manage or edit_subscription permissions)')
    });
    $dbh->do( q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 3, 'manage_additional_fields' FROM borrowers WHERE borrowernumber IN (SELECT DISTINCT borrowernumber FROM user_permissions WHERE code = 'order_manage' OR code = 'edit_subscription');
    });
    $dbh->do( q{
        INSERT INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 3, 'manage_additional_fields' FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM borrowers WHERE MOD(flags DIV POWER(2,11),2)=1 OR MOD(flags DIV POWER(2,15),2) =1);
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 15774 - Add permission for managing additional fields)\n";
}
