use Modern::Perl;

return {
    bug_number  => "24223",
    description => "Move contents of OpacNav system preference into additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OpacNav system preference
        my ($opacnav) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='OpacNav';
        |
        );
        if ($opacnav) {

            # If there is a value in the OpacNav preference, insert it into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'OpacNav', 'OpacNav', NULL, ?, ?, 'default', CAST(NOW() AS date) )",
                undef, "OpacNav default", $opacnav
            );

            # Remove the OpacNav system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OpacNav'");
        } else {
            say $out "No OpacNav preference found. Update has already been run.";
        }

    },
    }
