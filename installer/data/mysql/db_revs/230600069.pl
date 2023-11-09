use Modern::Perl;

return {
    bug_number  => "34869",
    description => "Move OPACResultsSidebar to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OPACResultsSidebar system preference
        my ($opacresultssidebar) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='OPACResultsSidebar';
        |
        );
        if ($opacresultssidebar) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'OPACResultsSidebar', 'OPACResultsSidebar', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'OPACResultsSidebar' AND location = 'OPACResultsSidebar' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'OPACResultsSidebar default', ?, 'default' )",
                undef, $insert_id, $opacresultssidebar
            );

            say $out "Added 'OpacMaintenanceNotice' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='OPACResultsSidebar'");
        say $out "Removed system preference 'OPACResultsSidebar'";

    },
};
