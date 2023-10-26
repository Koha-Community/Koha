use Modern::Perl;

return {
    bug_number  => "35065",
    description => "Move ILLModuleCopyrightClearance to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the ILLModuleCopyrightClearance system preference
        my ($illmodulecopyrightclearance) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='ILLModuleCopyrightClearance';
        |
        );
        if ($illmodulecopyrightclearance) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'ILLModuleCopyrightClearance', 'ILLModuleCopyrightClearance', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'ILLModuleCopyrightClearance' AND location = 'ILLModuleCopyrightClearance' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'ILLModuleCopyrightClearance default', ?, 'default' )",
                undef, $insert_id, $illmodulecopyrightclearance
            );

            say $out "Added 'ILLModuleCopyrightClearance' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='ILLModuleCopyrightClearance'");
        say $out "Removed system preference 'ILLModuleCopyrightClearance'";

    },
};
