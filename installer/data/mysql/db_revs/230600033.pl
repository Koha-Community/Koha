use Modern::Perl;

return {
    bug_number  => "34075",
    description => "Add DefaultAuthorityTab system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('DefaultAuthorityTab','0','0|1|2|3|4|5|6|7|8|9','Default tab to show when displaying authorities','Choice')
        }
        );
        say $out "Added new system preference 'DefaultAuthorityTab'";
    },
};
