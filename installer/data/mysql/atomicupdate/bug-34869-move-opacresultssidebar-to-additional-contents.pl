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
            foreach my $lang ('default') {
                $dbh->do(
                    "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'OPACResultsSidebar', 'OPACResultsSidebar', NULL, ?, ?, ?, CAST(NOW() AS date) )",
                    undef, "OPACResultsSidebar $lang", $opacresultssidebar, $lang
                );
            }

            # Remove old system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OPACResultsSidebar'");
            say $out "Bug 34869 update done";
        }
    }
    }
