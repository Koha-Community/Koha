use Modern::Perl;

return {
    bug_number => "24223",
    description => "Move contents of OpacNav system preference into additional contents",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # get list of installed translations
        require C4::Languages;
        my @langs;
        my $tlangs = C4::Languages::getTranslatedLanguages('opac','bootstrap');

        foreach my $language ( @$tlangs ) {
            foreach my $sublanguage ( @{$language->{'sublanguages_loop'}} ) {
                push @langs, $sublanguage->{'rfc4646_subtag'};
            }
        }

        # There must be a "default" entry in addition to language-specific ones
        push @langs, "default";

        # Get any existing value from the OpacNav system preference
        my ($opacnav) = $dbh->selectrow_array( q|
            SELECT value FROM systempreferences WHERE variable='OpacNav';
        |);
        if( $opacnav ){
            # If there is a value in the OpacNav preference, insert it into additional_contents
            my $code = '';
            foreach my $lang ( @langs ) {
                say $out "Inserting OpacNav contents into $lang news item...";
                $dbh->do( "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', '', 'OpacNav', NULL, ?, ?, ?, CAST(NOW() AS date) )", undef, "OpacNav $lang", $opacnav, $lang );
                my $idnew = $dbh->last_insert_id(undef, undef, 'additional_contents', undef);
                if( $code eq '' ){
                    $code = "News_$idnew";
                }
                $dbh->do(q|UPDATE additional_contents SET code=? WHERE idnew = ?|, undef, $code, $idnew);
            }

            # Remove the OpacNav system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OpacNav'");
            say $out "Bug 24223 update done";
        } else {
            say $out "No OpacNav preference found. Update has already been run.";
        }

    },
}
