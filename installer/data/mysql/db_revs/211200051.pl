use Modern::Perl;

return {
    bug_number  => "29925",
    description => "Add password reset option",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EnableExpiredPasswordReset', '0', NULL, 'Enable ability for patrons with expired password to reset their password directly', 'YesNo')
        }
        );
    },
};
