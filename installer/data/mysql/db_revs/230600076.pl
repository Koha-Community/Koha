use Modern::Perl;

return {
    bug_number  => "35048",
    description => "Move SCOMainUserBlock to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the SCOMainUserBlock system preference
        my ($scomainuserblock) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='SCOMainUserBlock';
        |
        );
        if ($scomainuserblock) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'SCOMainUserBlock', 'SCOMainUserBlock', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'SCOMainUserBlock' AND location = 'SCOMainUserBlock' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'SCOMainUserBlock default', ?, 'default' )",
                undef, $insert_id, $scomainuserblock
            );

            say $out "Added 'SCOMainUserBlock' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='SCOMainUserBlock'");
        say $out "Removed system preference 'SCOMainUserBlock'";

    },
};
