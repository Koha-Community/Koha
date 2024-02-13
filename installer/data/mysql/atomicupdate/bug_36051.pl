use Modern::Perl;

return {
    bug_number  => "36051",
    description => "Add option to specify SMS::Send driver parameters in a system preference instead of a file",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SMSSendAdditionalOptions', '', '', 'Additional SMS::Send parameters used to send SMS messages', 'free');
        }
        );

        say $out "Added new system preference 'SMSSendAdditionalOptions'";
    },
};
