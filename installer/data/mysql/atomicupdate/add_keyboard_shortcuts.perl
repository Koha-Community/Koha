$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless ( TableExists( 'keyboard_shortcuts' ) ) {
        $dbh->do(q|
            CREATE TABLE keyboard_shortcuts (
            shortcut_name varchar(80) NOT NULL,
            shortcut_keys varchar(80) NOT NULL,
            shortcut_desc varchar(200) NOT NULL,
            PRIMARY KEY (shortcut_name)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;|
        );
    }
    $dbh->do(q|
        INSERT IGNORE INTO keyboard_shortcuts (shortcut_name, shortcut_keys, shortcut_desc) VALUES
        ("insert_copyright","Alt-C","Insert copyright symbol (©)"),
        ("insert_copyright_sound","Alt-P","Insert copyright symbol (℗) (sound recordings)"),
        ("insert_delimiter","Ctrl-D","Insert delimiter (‡)"),
        ("subfield_help","Ctrl-H","Get help on current subfield"),
        ("link_authorities","Shift-Ctrl-L","Link field to authorities"),
        ("delete_field","Ctrl-X","Delete current field"),
        ("delete_subfield","Shift-Ctrl-X","Delete current subfield"),
        ("new_line","Enter","New field on next line"),
        ("line_break","Shift-Enter","Insert line break"),
        ("next_position","Tab","Move to next position"),
        ("prev_position","Shift-Tab","Move to previous position")
        ;|
    );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add keyboard_shortcuts table)\n";
}
