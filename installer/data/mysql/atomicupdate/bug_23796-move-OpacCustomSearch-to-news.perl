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

    # Get any existing value from the OpacCustomSearch system preference
    my ($OpacCustomSearch) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='OpacCustomSearch';
    |);
    if( $OpacCustomSearch ){
        foreach my $lang ( @langs ) {
            print "Inserting OpacCustomSearch contents into $lang news item...\n";
            # If there is a value in the OpacCustomSearch preference, insert it into opac_news
            $dbh->do("INSERT INTO opac_news (branchcode, lang, title, content ) VALUES (NULL, ?, '', ?)", undef, "OpacCustomSearch_$lang", $OpacCustomSearch);
        }
    }
    # Remove the OpacCustomSearch system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacCustomSearch'");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 23796: Convert OpacCustomSearch system preference to news block)\n";
}
