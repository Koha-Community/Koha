use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => 40435,
    description => "Add preference FutureHoldsBlockRenewals",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
            VALUES ('FutureHoldsBlockRenewals', 0, NULL, 'Allow future holds to block renewals', 'Integer' )}
        );

        say $out "Added new system preference 'FutureHoldsBlockRenewals'";
    },
};
