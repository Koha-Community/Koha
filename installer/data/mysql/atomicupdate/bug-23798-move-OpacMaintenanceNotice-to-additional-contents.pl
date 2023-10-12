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
                "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'OpacMaintenanceNotice', 'OpacMaintenanceNotice', NULL, 'OpacMaintenanceNotice default', ?, 'default', CAST(NOW() AS date) )",
                undef, $opacmaintenancenotice
            );

            # Remove old system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OpacMaintenanceNotice'");
            say $out "Bug 23798 update done";
        }
    }
    }
