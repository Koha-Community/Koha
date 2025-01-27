use Modern::Perl;

return {
    bug_number  => '30563',
    description => 'Add system preference RequireCashRegister',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('RequireCashRegister', '0', NULL, 'Require a cash register when collecting a payment', 'YesNo')
        }
        );
    },
};
