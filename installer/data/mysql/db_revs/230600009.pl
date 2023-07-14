use Modern::Perl;

return {
    bug_number  => "30979",
    description => "Add OPACTrustedCheckout system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('OpacTrustedCheckout', '0', NULL, 'Allow logged in OPAC users to check out to themselves', 'YesNo')
            }
        );
    },
};
