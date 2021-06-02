$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    $dbh->do('DELETE FROM sessions');
    $dbh->do('ALTER TABLE sessions MODIFY a_session LONGBLOB NOT NULL');

    NewVersion( $DBversion, '28489',
        'Modify sessions.a_session from longtext to longblob' );
}
