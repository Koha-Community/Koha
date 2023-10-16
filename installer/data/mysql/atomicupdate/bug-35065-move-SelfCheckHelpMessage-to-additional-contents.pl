use Modern::Perl;

return {
    bug_number  => "35065",
    description => "Move SelfCheckHelpMessage to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the SelfCheckHelpMessage system preference
        my ($selfcheckhelpmessage) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='SelfCheckHelpMessage';
        |
        );
        if ($selfcheckhelpmessage) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'SelfCheckHelpMessage', 'SelfCheckHelpMessage', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'SelfCheckHelpMessage' AND location = 'SelfCheckHelpMessage' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'SelfCheckHelpMessage default', ?, 'default' )",
                undef, $insert_id, $selfcheckhelpmessage
            );

            say $out "Added 'SelfCheckHelpMessage' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='SelfCheckHelpMessage'");
        say $out "Removed system preference 'SelfCheckHelpMessage'";

    },
};
