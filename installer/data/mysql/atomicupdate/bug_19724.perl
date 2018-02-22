$DBversion = 'XXX';
require C4::Installer;
if( CheckVersion( $DBversion ) ) {
    foreach my $table (qw(biblio_metadata deletedbiblio_metadata)) {
        if (!C4::Installer::column_exists($table, 'timestamp')) {
            $dbh->do(qq{
                ALTER TABLE `$table`
                ADD COLUMN `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `metadata`,
                ADD KEY `timestamp` (`timestamp`)
            });
            $dbh->do(qq{
                UPDATE $table metadata
                    LEFT JOIN biblioitems ON (biblioitems.biblionumber = metadata.biblionumber)
                    LEFT JOIN biblio ON (biblio.biblionumber = metadata.biblionumber)
                SET metadata.timestamp = GREATEST(biblioitems.timestamp, biblio.timestamp);
            });
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19724 - Add [deleted]biblio_metadata.timestamp)\n";
}
