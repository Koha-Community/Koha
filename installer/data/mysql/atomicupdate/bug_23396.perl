$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

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
            ("prev_position","Shift-Tab"),
            ("toggle_keyboard", "Shift-Ctrl-K")
    ;|);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23396 - Fix missing keyboard_shortcuts table)\n";
}