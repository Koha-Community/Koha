use Modern::Perl;

return {
    bug_number  => "23208",
    description => "Add system preference HoldRatioDefault",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('HoldRatioDefault','3','','Default value for the Hold ratio report','Integer')
        }
        );
        say $out "Added new system preference 'HoldRatioDefault'";
    },
};
