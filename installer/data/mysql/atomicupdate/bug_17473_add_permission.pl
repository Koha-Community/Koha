use Modern::Perl;

return {
    bug_number  => "17473",
    description => "Add void_payment permission",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE permissions (module_bit, code, description) VALUES
            (10, 'void_payment', 'Voiding Payments')
        });

        say $out "Added new permission 'void_payment'";

        $dbh->do(q{
            INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 10, 'void_payment' FROM user_permissions WHERE code = 'remaining_permissions'
        });
    },
};
