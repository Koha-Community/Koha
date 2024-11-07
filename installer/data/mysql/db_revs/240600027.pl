use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "27490",
    description => "Change language syspref to StaffInterfaceLanguages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{UPDATE systempreferences SET variable='StaffInterfaceLanguages' WHERE variable='language'});

        say_success( $out, "Updated system preference 'language' to 'StaffInterfaceLanguages'" );
    },
};
