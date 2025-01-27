use Modern::Perl;

return {
    bug_number  => "31274",
    description => "OPACSuggestionAutoFill must be 1 or 0",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences
            SET value = CASE
                            WHEN value='no'  THEN 0
                            WHEN value='yes' THEN 1
                            ELSE value
                        END
            WHERE variable='OPACSuggestionAutoFill';
        }
        );

        say $out "Updated system preference 'OPACSuggestionAutoFill'";
    },
};
