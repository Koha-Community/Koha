use Modern::Perl;

return {
    bug_number  => "34557",
    description => "Add system preference SCOLoadCheckoutsByDefault",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SCOLoadCheckoutsByDefault','1','','If enabled, load the list of a patrons checkouts when they log in to the Self Checkout','YesNo')
        }
        );

        say $out "Added new system preference 'SCOLoadCheckoutsByDefault'";
    },
};
