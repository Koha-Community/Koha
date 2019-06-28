$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO keyboard_shortcuts (shortcut_name, shortcut_keys)
            VALUES ("toggle_keyboard", "Shift-Ctrl-K")
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17178 - add shortcut to keyboard_shortcuts)\n";
}
