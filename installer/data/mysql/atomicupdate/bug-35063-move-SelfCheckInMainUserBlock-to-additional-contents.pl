use Modern::Perl;

return {
    bug_number  => "35063",
    description => "Move SelfCheckInMainUserBlock to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the SelfCheckInMainUserBlock system preference
        my ($scimainuserblock) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='SelfCheckInMainUserBlock';
        |
        );
        if ($scimainuserblock) {

            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'SelfCheckInMainUserBlock', 'SelfCheckInMainUserBlock', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'SelfCheckInMainUserBlock' AND location = 'SelfCheckInMainUserBlock' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'SelfCheckInMainUserBlock default', ?, 'default' )",
                undef, $insert_id, $scimainuserblock
            );

            say $out "Added 'SelfCheckInMainUserBlock' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='SelfCheckInMainUserBlock'");
        say $out "Removed system preference 'SelfCheckInMainUserBlock'";

    },
};
