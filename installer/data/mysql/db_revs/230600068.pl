use Modern::Perl;

return {
    bug_number  => "23798",
    description => "Convert OpacMaintenanceNotice system preference to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OpacMaintenanceNotice system preference
        my ($opacmaintenancenotice) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='OpacMaintenanceNotice';
        |
        );
        if ($opacmaintenancenotice) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'OpacMaintenanceNotice', 'OpacMaintenanceNotice', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'OpacMaintenanceNotice' AND location = 'OpacMaintenanceNotice' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'OpacMaintenanceNotice default', ?, 'default' )",
                undef, $insert_id, $opacmaintenancenotice
            );

            say $out "Added 'OpacMaintenanceNotice' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='OpacMaintenanceNotice'");
        say $out "Removed system preference 'OpacMaintenanceNotice'";

    },
};
