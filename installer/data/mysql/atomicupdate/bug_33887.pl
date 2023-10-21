use Modern::Perl;

return {
    bug_number  => "33887",
    description => "Automatically fill the next hold with a automatic check in.",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('AutomaticCheckinAutoFill', '0', NULL,'Automatically fill the next hold with an automatic checkin cronjob.', 'YesNo') }
        );

        # Print useful stuff here
        # sysprefs
        say $out "Added new system preference 'AutomaticCheckinAutoFill'";
    },
};
