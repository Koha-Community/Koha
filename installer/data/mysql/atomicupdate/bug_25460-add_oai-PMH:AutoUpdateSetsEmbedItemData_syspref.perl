$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('OAI-PMH:AutoUpdateSetEmbedItemData', '0', '', 'Embed item information when automatically updating OAI sets. Requires OAI-PMH:AutoUpdateSets syspref to be enabled', 'YesNo') });

    $dbh->do(q{ UPDATE systempreferences SET explanation = 'Automatically update OAI sets when a bibliographic or item record is created or updated' WHERE variable = 'OAI-PMH:AutoUpdateSets' });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 25460 - Update OAI set when adding/editing/deleting item records)\n";
}
