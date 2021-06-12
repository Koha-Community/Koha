$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    $dbh->do(
        qq{
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (4, 'delete_borrowers', 'Delete borrowers')
    }
    );

    $dbh->do(q{
        INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
        SELECT borrowernumber, 4, 'delete_borrowers' FROM user_permissions WHERE code = 'edit_borrowers'
    });

    NewVersion( $DBversion, 15788, "Split edit_borrowers permission" );
}
