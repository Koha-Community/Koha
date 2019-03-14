$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $table_sth = $dbh->prepare('SHOW CREATE TABLE `search_marc_map`');
    $table_sth->execute();
    my @table = $table_sth->fetchrow_array();
    unless ( $table[1] =~ /`marc_field`.*COLLATE utf8mb4_bin/ ) { #catches utf8mb4 collated tables
        $dbh->do("ALTER TABLE `search_marc_map` MODIFY `marc_field` VARCHAR(255) NOT NULL COLLATE utf8mb4_bin COMMENT 'the MARC specifier for this field'");
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
	print "Upgrade to $DBversion done (Bug 19670 - Change collation of marc_field to allow mixed case search field mappings)\n";
}
