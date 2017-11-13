$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do(q{ALTER TABLE biblio_data_elements ADD COLUMN encoding_level varchar(1);});
	$dbh->do(q{ALTER TABLE biblio_data_elements ADD KEY `encoding_level` (`encoding_level`);});
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-257-3 - Add 'Encoding level' to the Biblio data elements -table)\n";
}
