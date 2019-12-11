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

    # Get any existing value from the OpacMainUserBlock system preference
    my ($opacmainuserblock) = $dbh->selectrow_array( q|
        SELECT value FROM systempreferences WHERE variable='OpacMainUserBlock';
    |);
    if( $opacmainuserblock ){
        foreach my $lang ( @langs ) {
            print "Inserting OpacMainUserBlock contents into $lang news item...\n";
            # If there is a value in the OpacMainUserBlock preference, insert it into opac_news
            $dbh->do("INSERT INTO opac_news (branchcode, lang, title, content ) VALUES (NULL, ?, '', ?)", undef, "OpacMainUserBlock_$lang", $opacmainuserblock);
        }
    }
    # Remove the OpacMainUserBlock system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='OpacMainUserBlock'");
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug 23794: Move contents of OpacMainUserBlock preference to Koha news system)\n";
}
