use Modern::Perl;

return {
    bug_number  => "29822",
    description => "Convert DefaultPatronSeachFields from csv to psv",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            UPDATE systempreferences
            SET
              value = REPLACE( value, ',', '|' )
            WHERE
              variable = 'DefaultPatronSearchFields'
        }
        );
        say $out "Updated system preference 'DefaultPatronSearchFields";
    },
};
