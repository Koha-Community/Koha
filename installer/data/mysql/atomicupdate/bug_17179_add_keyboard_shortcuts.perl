$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO keyboard_shortcuts (shortcut_name, shortcut_keys) VALUES
        ("copy_line","Ctrl-C"),
        ("copy_subfield","Shift-Ctrl-C"),
        ("paste_line","Ctrl-P"),
        ("insert_line","Ctrl-I")
        ;
    |);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17179 - Add additional keyboard_shortcuts)\n";
}
