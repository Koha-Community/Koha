use Modern::Perl;

return {
    bug_number  => "33887",
    description => "Automatically fill the next hold with a automatic check in.",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('AutomaticCheckinAutoFill', '0', NULL,'Automatically fill the next hold with an automatic checkin cronjob.', 'YesNo') }
        );

        say $out "Added new system preference 'AutomaticCheckinAutoFill'";
    },
};
