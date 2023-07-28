use Modern::Perl;

return {
    bug_number  => "33664",
    description => "Allow cancelling of orders from closed baskets",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES
            ('CancelOrdersInClosedBaskets', '0', NULL, 'Allow/Do not allow cancelling order lines in closed baskets.', 'YesNo')
        }
        );

        # sysprefs
        say $out "Added new system preference 'CancelOrdersInClosedBaskets'";
    },
};
