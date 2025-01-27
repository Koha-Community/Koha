use Modern::Perl;

return {
    bug_number  => "24224",
    description => "Move contents of OpacNavBottom system preference into additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OpacNavBottom system preference
        my ($opacnavbottom) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='OpacNavBottom';
        |
        );
        if ($opacnavbottom) {

            # If there is a value in the OpacNavBottom preference, insert it into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'OpacNavBottom', 'OpacNavBottom', NULL, ?, ?, 'default', CAST(NOW() AS date) )",
                undef, "OpacNavBottom default", $opacnavbottom
            );

            # Remove the OpacNavBottom system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OpacNavBottom'");
        } else {
            say $out "No OpacNavBottom preference found. Update has already been run.";
        }

    },
    }
