$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (27, 'recalls', 'Recalls', 0) });
    $dbh->do(q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (27, 'manage_recalls', 'Manage recalls for patrons') });

    NewVersion( $DBversion, 19532, "Add recalls user flag and manage_recalls user permission" );
}
