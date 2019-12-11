$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # get list of installed translations
    require C4::Languages;
    my @langs;
    my $tlangs = C4::Languages::getTranslatedLanguages();

    foreach my $language ( @$tlangs ) {
        foreach my $sublanguage ( @{$language->{'sublanguages_loop'}} ) {
            push @langs, $sublanguage->{'rfc4646_subtag'};
        }
    }

    # Get any existing value from the opaccredits system preference
    my ($opaccredits) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='opaccredits';
    |);
    if( $opaccredits ){
        foreach my $lang ( @langs ) {
            print "Inserting opaccredits contents into $lang news item...\n";
            # If there is a value in the opaccredits preference, insert it into opac_news
            $dbh->do("INSERT INTO opac_news (branchcode, lang, title, content ) VALUES (NULL, ?, '', ?)", undef, "opaccredits_$lang", $opaccredits);
        }
    }
    # Remove the opaccredits system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='opaccredits'");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 23795: Convert OpacCredits system preference to news block)\n";
}
