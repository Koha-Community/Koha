$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $opaclang = C4::Context->preference("opaclanguages");
    my @langs;
    push @langs, split ( '\,', $opaclang );
    # Get any existing value from the opacheader system preference
    my ($opacheader) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='opacheader';
    |);
    if( $opacheader ){
        foreach my $lang ( @langs ) {
            print "Inserting opacheader contents into $lang news item...\n";
            # If there is a value in the opacheader preference, insert it into opac_news
            $dbh->do("INSERT INTO opac_news (branchcode, lang, title, content ) VALUES (NULL, ?, '', ?)", undef, "opacheader_$langs[0]", $opacheader);
        }
    }
    # Remove the opacheader system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='opacheader'");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 22880: Move contents of opacheader preference to Koha news system)\n";
}
