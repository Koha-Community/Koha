use Modern::Perl;

return {
    bug_number  => "24221",
    description => "Move OpacMySummaryNote to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the OpacMySummaryNote system preference
        my ($opacmysummarynote) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable='OPACMySummaryNote';
        }
        );
        if ($opacmysummarynote) {
            $dbh->do(
                q{
                INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on )
                VALUES ('html_customizations', 'OpacMySummaryNote', 'OpacMySummaryNote', NULL, ?, ?, ?, CAST(NOW() AS date) )
            }, undef, "OpacMySummaryNote default", $opacmysummarynote, 'default'
            );

            # Remove old system preference
            $dbh->do(
                q{
                DELETE FROM systempreferences WHERE variable='OPACMySummaryNote'
            }
            );
        } else {
            say $out "No OpacMySummaryNote preference found. Value was empty or update has already been run.";
        }
    },
};
