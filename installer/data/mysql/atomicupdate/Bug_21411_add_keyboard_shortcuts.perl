$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless ( TableExists( 'keyboard_shortcuts' ) ) {
        $dbh->do(q|
            CREATE TABLE keyboard_shortcuts (
            shortcut_name varchar(80) NOT NULL,
            shortcut_keys varchar(80) NOT NULL,
            PRIMARY KEY (shortcut_name)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;|
        );
    }
    $dbh->do(q|
        INSERT IGNORE INTO keyboard_shortcuts (shortcut_name, shortcut_keys) VALUES
        ("insert_copyright","Alt-C"),
        ("insert_copyright_sound","Alt-P"),
        ("insert_delimiter","Ctrl-D"),
        ("subfield_help","Ctrl-H"),
        ("link_authorities","Shift-Ctrl-L"),
        ("delete_field","Ctrl-X"),
        ("delete_subfield","Shift-Ctrl-X"),
        ("new_line","Enter"),
        ("line_break","Shift-Enter"),
        ("next_position","Tab"),
        ("prev_position","Shift-Tab")
        ;|
    );
    $dbh->do(q|
        INSERT IGNORE permissions (module_bit, code, description)
        VALUES
        (3,'manage_keyboard_shortcuts','Manage keyboard shortcuts for advanced cataloging editor')
        ;|
    );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add keyboard_shortcuts table)\n";
}
