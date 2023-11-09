use Modern::Perl;

return {
    bug_number  => "34889",
    description => "Move PatronSelfRegistrationAdditionalInstructions to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the PatronSelfRegistrationAdditionalInstructions system preference
        my ($patronselfregistrationadditionalinstructions) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='PatronSelfRegistrationAdditionalInstructions';
        |
        );
        if ($patronselfregistrationadditionalinstructions) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'PatronSelfRegistrationAdditionalInstructions', 'PatronSelfRegistrationAdditionalInstructions', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'PatronSelfRegistrationAdditionalInstructions' AND location = 'PatronSelfRegistrationAdditionalInstructions' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'PatronSelfRegistrationAdditionalInstructions default', ?, 'default' )",
                undef, $insert_id, $patronselfregistrationadditionalinstructions
            );

            say $out "Added 'PatronSelfRegistrationAdditionalInstructions' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='PatronSelfRegistrationAdditionalInstructions'");
        say $out "Removed system preference 'PatronSelfRegistrationAdditionalInstructions'";

    },
};
