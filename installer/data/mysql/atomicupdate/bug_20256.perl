$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 9, 'edit_any_item', 'Edit any item reguardless of home library');" );

    $dbh->do(q{
        INSERT INTO user_permissions ( borrowernumber, module_bit, code )
        SELECT borrowernumber, '9', 'edit_any_item'
        FROM user_permissions
        WHERE module_bit = '9'
          AND code = 'edit_items'
    });

    if ( !column_exists( 'library_groups', 'ft_limit_item_editing' ) ) {
        $dbh->do( "ALTER TABLE library_groups ADD COLUMN ft_limit_item_editing tinyint(1) NOT NULL DEFAULT 0 AFTER ft_hide_patron_info" );
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20256 - Add ability to limit editing of items to home library)\n";
}
