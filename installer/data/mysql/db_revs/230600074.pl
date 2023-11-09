use Modern::Perl;

return {
    bug_number  => "34894",
    description => "Move OpacSuppressionMessage to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OpacSuppressionMessage system preference
        my ($opacsuppressionmessage) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='OpacSuppressionMessage';
        |
        );
        if ($opacsuppressionmessage) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'OpacSuppressionMessage', 'OpacSuppressionMessage', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'OpacSuppressionMessage' AND location = 'OpacSuppressionMessage' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'OpacSuppressionMessage default', ?, 'default' )",
                undef, $insert_id, $opacsuppressionmessage
            );

            say $out "Added 'OpacSuppressionMessage' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='OpacSuppressionMessage'");
        say $out "Removed system preference 'OpacSuppressionMessage'";

    },
};
