use Modern::Perl;

return {
    bug_number  => "30226",
    description => "Add the system preference AllowSetAutomaticRenewal",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` ) VALUES('AllowSetAutomaticRenewal', '1', NULL, 'If ON, allows staff to flag items for automatic renewal on the check out page', 'YesNo')
        }
        );
    },
};
