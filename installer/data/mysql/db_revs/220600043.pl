use Modern::Perl;

return {
    bug_number  => "20058",
    description => "Option to use shelving location instead of homebranch for sorting",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
('UseLocationAsAQInSIP', '0', '', 'Use permanent_location instead of homebranch for AQ in SIP response', 'YesNo')}
        );

        say $out "Added new system preference 'UseLocationAsAQInSIP'";
    },
    }
