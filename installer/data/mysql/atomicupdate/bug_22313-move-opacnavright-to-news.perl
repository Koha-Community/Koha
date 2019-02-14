$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $opaclang = C4::Context->preference("opaclanguages");
    my @langs;
    push @langs, split ( '\,', $opaclang );
    # Get any existing value from the OpacNavRight system preference
    my ($OpacNavRight) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='OpacNavRight';
    |);
    if( $OpacNavRight ){
        # If there is a value in the OpacNavRight preference, insert it into opac_news
        $dbh->do("INSERT INTO opac_news (branchcode, lang, title, content ) VALUES (NULL, 'OpacNavRight_$langs[0]', '', '$OpacNavRight')");
    }
    # Remove the OpacNavRight system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacNavRight'");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 22318: Move contents of OpacNavRight preference to Koha news system)\n";
}
